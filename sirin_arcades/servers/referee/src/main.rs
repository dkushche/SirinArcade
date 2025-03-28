use crate::State::{PendingFirstPlayer, RunLobbySystemAsset, RunLogoSystemAsset, RunMenuSystemAsset};
use events_bus::ap_types::{
    ClientToServerEvent, ServerToSoTransitEvent, ServerToSoTransitEventType, SoToClient,
    SoToServerEvent, SoToServerTransitBack, SoToServerTransitBackArray,
};
use libc::free;
use libloading::Library;
use std::collections::HashMap;
use std::env;
use std::ffi::c_void;
use std::fs::FileType;
use std::mem::transmute;
use std::net::SocketAddr;
use std::path::{Path, StripPrefixError};
use std::str::FromStr;
use std::sync::atomic::{AtomicBool, Ordering};
use std::sync::Arc;
use std::time::Duration;
use tokio::io::{AsyncReadExt, AsyncWriteExt};
use tokio::net::tcp::{OwnedReadHalf, OwnedWriteHalf};
use tokio::net::{TcpListener, UdpSocket};
use tokio::sync::{Mutex, Notify};
use tokio::time::{interval, sleep};
use walkdir::WalkDir;

const WINDOW_RESOLUTION_SIZE: usize = size_of::<u8>() * 2usize;

struct GameServer {
    assets_dir: String,
    supplier_addr: String,

    beacon_socket: Arc<UdpSocket>,
    listener: TcpListener,

    clients_connections_read_halfs: Arc<Mutex<HashMap<SocketAddr, OwnedReadHalf>>>,
    clients_connections_write_halfs: HashMap<SocketAddr, OwnedWriteHalf>,

    state: State,
}

#[derive(Debug)]
enum StateError {
    OtherStateRequired,
}

enum State {
    PendingFirstPlayer,
    RunLogoSystemAsset,
    RunMenuSystemAsset,
    RunLobbySystemAsset,
    RunGame,
}

const SYSTEM_ARCADES_LOGO_PATH: &str = "liblogo_arcade";
const SYSTEM_ARCADES_MENU_PATH: &str = "libmenu_arcade";
const SYSTEM_ARCADES_LOBBY_PATH: &str = "liblobby_arcade";

const FRAME_RATE_PER_SEC: usize = 30;

struct RunningLibrary {
    library: Library,
    game_frame_fn: unsafe extern "C" fn(
        first_event: *const ServerToSoTransitEvent,
        length: usize,
    ) -> SoToServerTransitBackArray,
}

impl RunningLibrary {
    fn new(assets_dir: &str, path_from_assets: &str) -> RunningLibrary {
        // example for path: system/logo/libexample"
        let library = unsafe {
            Library::new(format!("{assets_dir}/{path_from_assets}.so"))
                .expect("there are no library")
        };

        let game_frame_fn = *unsafe {
            library
                .get(b"game_frame")
                .expect("game_frame must be present in library")
        };

        RunningLibrary {
            library,
            game_frame_fn,
        }
    }
}

impl GameServer {
    async fn new(
        server_port: String,
        client_port: String,
        assets_dir: String,
        supplier_addr: String,
    ) -> Self {
        let beacon_socket = UdpSocket::bind("0.0.0.0:0").await.unwrap();
        beacon_socket.set_broadcast(true).unwrap();
        beacon_socket
            .connect(
                &SocketAddr::from_str(format!("255.255.255.255:{}", client_port).as_str()).unwrap(),
            )
            .await
            .expect("panic with setting things up");

        let listener = TcpListener::bind(format!("0.0.0.0:{}", server_port).as_str())
            .await
            .unwrap();

        GameServer {
            assets_dir,
            supplier_addr,

            beacon_socket: Arc::new(beacon_socket),
            listener,

            clients_connections_read_halfs: Arc::new(Mutex::new(HashMap::new())),
            clients_connections_write_halfs: HashMap::new(),
            state: State::PendingFirstPlayer,
        }
    }

    async fn run_forever(&mut self) {
        loop {
            match self.state {
                State::PendingFirstPlayer => self.handle_pending_first_player().await,
                State::RunLogoSystemAsset => self.handle_run_logo_system_asset().await,
                State::RunMenuSystemAsset => self.handle_run_menu_system_asset().await,
                State::RunLobbySystemAsset => self.handle_run_lobby_system_asset().await,
                State::RunGame => self.handle_run_game().await,
            }
            .unwrap();
        }
    }

    async fn handle_pending_first_player(&mut self) -> Result<(), StateError> {
        if let State::PendingFirstPlayer = &self.state {
            let cloned_beacon_socket = Arc::clone(&self.beacon_socket);
            let udp_client_thread_join_handle = tokio::spawn(async move {
                let mut to_send = 180i32.to_be_bytes().to_vec(); //todo constants and another values, and also do not forget about endianness
                to_send.push(';' as u8);
                to_send.extend_from_slice(&48i32.to_be_bytes());
                to_send.push(';' as u8);

                loop {
                    sleep(Duration::from_secs(2)).await;
                    println!("sent");

                    cloned_beacon_socket
                        .send(to_send.as_slice()) //todo 48 ->54
                        .await
                        .expect("socket not connected");
                }
            });

            loop {
                let (tcp_stream, addr) = self.listener.accept().await.unwrap();
                let (mut read_half, write_half) = tcp_stream.into_split();

                let mut handshake_buf = [0u8; 1];
                match read_half.read_exact(&mut handshake_buf).await {
                    Err(_) | Ok(0) => {} // connection closed
                    Ok(_) => {
                        if handshake_buf[0] == 0 {
                            self.clients_connections_read_halfs
                                .lock()
                                .await
                                .insert(addr, read_half);
                            self.clients_connections_write_halfs
                                .insert(addr, write_half);

                            self.state = RunLogoSystemAsset;

                            udp_client_thread_join_handle.abort();
                            return Ok(());
                        }
                    }
                }
            }
        } else {
            Err(StateError::OtherStateRequired)
        }
    }

    async fn handle_run_logo_system_asset(&mut self) -> Result<(), StateError> {
        if let State::RunLogoSystemAsset = &self.state {
            let lib = RunningLibrary::new(self.assets_dir.as_str(), SYSTEM_ARCADES_LOGO_PATH);
            let clients_events_buf: Arc<Mutex<Vec<ServerToSoTransitEvent>>> =
                Arc::new(Mutex::new(Vec::new()));
            for entry in WalkDir::new("/sirin_arcades/arcades/logo/resources/") //todo possibly not this folder and logic may be changed with other folder
                .into_iter()
                .filter_map(|e| {
                    e.ok()
                        .and_then(|ret| ret.file_type().is_file().then_some(ret))
                })
            {
                let mut base_end = String::from(self.supplier_addr.as_str());
                match entry
                    .path()
                    .strip_prefix("/sirin_arcades/arcades")
                    .map(|path| path.to_str())
                {
                    Ok(Some(path)) => base_end.push_str(path),
                    _ => {
                        continue;
                    }
                }
                //base end example http://127.0.0.1:5589/logo/resources/intro.wav
                println!("{}", base_end);

                if base_end.len() > 99 {
                    // because LoadResource data is 100 bytes array
                    continue;
                }

                let mut buffer = [0u8; 100];
                buffer[base_end.len()] = 0;
                buffer[..base_end.len()].copy_from_slice(base_end.as_bytes());
                let so_to_client = SoToClient::LoadResource {
                    data: unsafe { transmute(buffer) },
                }; // untested
                println!("{so_to_client:?}");

                // todo send to users
                for (_addr, write_conn) in self.clients_connections_write_halfs.iter_mut() {
                    // якщо коннект обірвався то unwrap може видать паніку broken pipe, треба обробка поведінки розриву конекту що під час read що під час write
                    unsafe { write_conn.write_all(std::slice::from_raw_parts(&so_to_client as *const SoToClient as *const u8, size_of::<SoToClient>())).await.unwrap(); }
                    // println!("sent so to client ");
                }
            }

            let returning_readers = Arc::new(AtomicBool::new(false));
            let stop_notify = Arc::new(Notify::new());
            for (addr, mut read_half_for_this_id) in
                self.clients_connections_read_halfs.lock().await.drain()
            {
                let clients_events_buf_cloned = Arc::clone(&clients_events_buf);
                let returning_readers_cloned = Arc::clone(&returning_readers);
                let clients_connections_read_halfs_cloned =
                    Arc::clone(&self.clients_connections_read_halfs);
                let notify_clone = Arc::clone(&stop_notify);
                tokio::spawn(async move {
                    loop {
                        if returning_readers_cloned.load(Ordering::SeqCst) {
                            clients_connections_read_halfs_cloned
                                .lock()
                                .await
                                .insert(addr, read_half_for_this_id);
                            print!("yeah water returned");
                            break;
                        }
                        let mut exact_event_buf = [0; size_of::<ClientToServerEvent>()];
                        tokio::select! {
                            _ = notify_clone.notified() => {
                                continue;
                            }
                            read_exact_res = read_half_for_this_id.read_exact(&mut exact_event_buf) => {
                                match read_exact_res {
                                    Ok(_) => {
                                        let client_to_server_event = unsafe {
                                            (exact_event_buf.as_ptr() as *const ClientToServerEvent)
                                                .as_ref()
                                                .unwrap()
                                        };
                                        //println!("got event from {}: {:?} ", id, client_to_server_event);

                                        let mut extended = [0u8; 32];

                                        match &addr {
                                            SocketAddr::V4(v4) => {
                                                extended[..4].copy_from_slice(&v4.ip().octets());
                                                extended[16..18].copy_from_slice(&v4.port().to_be_bytes());
                                            }
                                            SocketAddr::V6(v6) => {
                                                extended[..16].copy_from_slice(&v6.ip().octets());
                                                extended[16..18].copy_from_slice(&v6.port().to_be_bytes());
                                            }
                                        }
                                        clients_events_buf_cloned.lock().await.push(
                                            ServerToSoTransitEvent {
                                                client_id: extended,
                                                underlying_event: ServerToSoTransitEventType {
                                                    client_event: *client_to_server_event,
                                                },
                                            },
                                        );
                                    }
                                    _ => {
                                        // todo вбити асінк таску та перейти в минулий стейт?
                                        returning_readers_cloned.store(true, Ordering::SeqCst);
                                    } // "operation encounters an "end of file" before completely filling the buffer". including connection closing
                                }
                            }
                        }
                    }
                    println!(" to the well");
                });
            }

            let mut so_to_server_transit_events = None;
            let interval_duration = Duration::from_secs_f64(1.0 / FRAME_RATE_PER_SEC as f64);
            let mut interval = interval(interval_duration);
            'a: loop {
                // todo? перевірка returning_readers
                interval.tick().await;
                let result = {
                    let copy = {
                        let mut guard = clients_events_buf.lock().await;
                        guard.drain(..).collect::<Vec<_>>()
                    };

                    // println!("{copy:?}");
                    unsafe { (lib.game_frame_fn)(copy.as_ptr(), copy.len()) }
                };
                if so_to_server_transit_events.is_none() {
                    so_to_server_transit_events = Some(result.first_element);
                }

                println!("beginning transit so -> client");

                // important: there is a necessity to handle each event (for at least freeing possible pointers passed to server)
                for event in
                    unsafe { std::slice::from_raw_parts(result.first_element, result.length) }
                {
                    match event {
                        SoToServerTransitBack::ToClient(so_to_client) => {
                            for (_addr, write_conn) in
                                self.clients_connections_write_halfs.iter_mut()
                            {
                                // можливе покращення: настворить тасок і почекати їх виконання(?) можливо навіть на кожен івент замість про на кожен конект
                                println!("sent this event {:?}", so_to_client);
                                // якщо коннект обірвався то unwrap може видать паніку broken pipe, треба обробка поведінки розриву конекту що під час read що під час write
                                // write_sotoclient!(write_conn, so_to_client);
                                unsafe {
                                    if let Err(_) = write_conn
                                        .write_all(std::slice::from_raw_parts(
                                            so_to_client as *const _ as *const u8,
                                            std::mem::size_of::<SoToClient>(),
                                        ))
                                        .await {
                                        returning_readers.store(true, Ordering::SeqCst);

                                        break 'a;
                                    }
                                }
                            }
                        }
                        SoToServerTransitBack::ToServer(SoToServerEvent::GoToState(_state)) => {
                            // idk
                            break 'a;
                        }
                        _ => {
                            panic!("you are punished");
                        }
                    }
                }
                println!("transit so -> client ended");
            }

            if returning_readers.load(Ordering::SeqCst) {
                self.state = PendingFirstPlayer;
                // maybe just kill any connection

                // todo clean up clients_connections_read_halfs and clients_connections_write_halfs ?
                // free(so_to_server_transit_events.unwrap() as *mut c_void); ?
                // cleaning client resources?


                //  todo consider same treatment as in else arm
                // part of treatment:
                stop_notify.notify_waiters();
                // Ok(())
            } else {
                self.state = RunMenuSystemAsset;

                let so_to_client = SoToClient::CleanResources;
                for (_addr, write_conn) in self.clients_connections_write_halfs.iter_mut() {
                    // якщо коннект обірвався то unwrap може видать паніку broken pipe, треба обробка поведінки розриву конекту що під час read що під час write
                    // write_sotoclient!(write_conn, so_to_client);
                    unsafe {
                        let _ = write_conn
                            .write_all(std::slice::from_raw_parts(
                                &so_to_client as *const _ as *const u8,
                                std::mem::size_of::<SoToClient>(),
                            ))
                            .await;
                    }
                    // println!("sent so to client ");
                }

                returning_readers.store(true, Ordering::SeqCst);
                while self.clients_connections_read_halfs.lock().await.len()
                    != self.clients_connections_write_halfs.len()
                {
                    tokio::time::sleep(Duration::from_millis(100)).await;
                    println!("still waiting {} {}", self.clients_connections_read_halfs.lock().await.len(), self.clients_connections_write_halfs.len());
                    stop_notify.notify_waiters();
                }

                unsafe {
                    free(so_to_server_transit_events.unwrap() as *mut c_void);
                }
            }
            Ok(())
        } else {
            Err(StateError::OtherStateRequired)
        }
    }

    async fn handle_run_menu_system_asset(&mut self) -> Result<(), StateError> {
        if let State::RunMenuSystemAsset = &self.state {
            unimplemented!("run menu is unimplemented");
            self.state = RunLobbySystemAsset;
        } else {
            Err(StateError::OtherStateRequired)
        }
    }

    async fn handle_run_lobby_system_asset(&mut self) -> Result<(), StateError> {
        if let State::RunLobbySystemAsset = &self.state {
            todo!()
            //todo перестворити beacon з новим width;height;game_name
        } else {
            Err(StateError::OtherStateRequired)
        }
    }

    async fn handle_run_game(&mut self) -> Result<(), StateError> {
        if let State::RunGame = &self.state {
            todo!()
        } else {
            Err(StateError::OtherStateRequired)
        }
    }
}

#[tokio::main]
async fn main() {
    let server_port =
        env::var("SIRIN_ARCADE_SERVER_PORT").expect("SIRIN_ARCADE_SERVER_PORT must be set");

    let client_port =
        env::var("SIRIN_ARCADE_CLIENT_PORT").expect("SIRIN_ARCADE_CLIENT_PORT must be set");

    let assets_dir =
        env::var("SIRIN_ARCADE_ASSETS_DIR").expect("SIRIN_ARCADE_ASSETS_DIR must be set");

    let supply_server_addr =
        env::var("SIRIN_SUPPLIER_ADDR").expect("SIRIN_SUPPLIER_ADDR must be set"); // http://127.0.0.1:5589/

    let mut server =
        GameServer::new(server_port, client_port, assets_dir, supply_server_addr).await;

    server.run_forever().await;
}
