use crate::State::{
    RunLobbySystemAsset, RunLogoSystemAsset, RunMenuSystemAsset,
};
use std::collections::{HashMap};
use std::env;
use std::ffi::c_void;
use std::net::{SocketAddr};
use std::str::FromStr;
use std::sync::Arc;
use std::time::Duration;
use libc::free;
use events_bus::ap_types::{
    ClientToServerEvent, ServerToSoTransitEvent, ServerToSoTransitEventType,
    SoToClient, SoToServerEvent, SoToServerTransitBack, SoToServerTransitBackArray
};
use libloading::Library;
use tokio::io::{AsyncReadExt, AsyncWriteExt};
use tokio::net::{TcpListener, UdpSocket};
use tokio::net::tcp::{OwnedReadHalf, OwnedWriteHalf};
use tokio::sync::Mutex;
use tokio::time::sleep;
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
}

const SYSTEM_ARCADES_LOGO_PATH: &str = "liblogo_arcade";
const SYSTEM_ARCADES_MENU_PATH: &str = "libmenu_arcade";
const SYSTEM_ARCADES_LOBBY_PATH: &str = "liblobby_arcade";

struct RunningLibrary {
    library: Library,
    game_frame_fn: unsafe extern "C" fn(first_event: *const ServerToSoTransitEvent, length: usize) -> SoToServerTransitBackArray,
}

impl RunningLibrary {
    fn new(assets_dir: &str, path_from_assets: &str) -> RunningLibrary { // example for path: system/logo/libexample"
        let library = unsafe {
            Library::new(format!("{assets_dir}/{path_from_assets}.so"))
                .expect("there are no library")
        };

        let game_frame_fn = *unsafe { library.get(b"game_frame").expect("game_frame must be present in library") };

        RunningLibrary {
            library,
            game_frame_fn,
        }
    }
}

impl GameServer {
    async fn new(server_port: String, client_port: String, assets_dir: String, supplier_addr: String) -> Self {
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
            state: State::PendingFirstPlayer
        }
    }

    async fn run_forever(&mut self) {
        loop {
            match self.state {
                State::PendingFirstPlayer => self.handle_pending_first_player().await,
                State::RunLogoSystemAsset => self.handle_run_logo_system_asset().await,
                State::RunMenuSystemAsset => self.handle_run_menu_system_asset().await,
                State::RunLobbySystemAsset => self.handle_run_lobby_system_asset().await,
            };
        }
    }

    async fn handle_pending_first_player(&mut self) -> Result<(), StateError> {
        if let State::PendingFirstPlayer = &self.state {
            let cloned_beacon_socket = Arc::clone(&self.beacon_socket);
            let udp_client_thread_join_handle = tokio::spawn(async move {
                loop {
                    sleep(Duration::from_secs(2)).await;
                    println!("sent");
                    cloned_beacon_socket
                        .send("0;0;".as_bytes())
                        .await
                        .expect("socket not connected");
                }
            });

            loop {
                let (mut tcp_stream, addr) = self.listener.accept().await.unwrap();

                let mut buffer = [0u8; WINDOW_RESOLUTION_SIZE];
                match tcp_stream.read_exact(&mut buffer).await {
                    Ok(0) => {
                        println!("Client {} disconnected.", addr);
                        todo!("do not forget about possibility of timed out or conn closing");
                    }
                    Ok(WINDOW_RESOLUTION_SIZE) => {
                        let width = buffer[0];
                        let height = buffer[1];
                        println!("{width}, {height}");
                        {
                            let (read_half, write_half) = tcp_stream.into_split();

                            self.clients_connections_read_halfs.lock().await.insert(addr, read_half);
                            self.clients_connections_write_halfs.insert(addr, write_half);
                        }

                        self.state = RunLogoSystemAsset;

                        break;
                    }
                    Ok(_n) => {
                        todo!("this match arm represents possibility of sending something with less size than needed (1 at the moment this comment was written...)")
                    }
                    Err(e) => {
                        println!("Error reading from {}: {}", addr, e);
                    }
                }
            }

            udp_client_thread_join_handle.abort();
            Ok(())
        } else {
            Err(StateError::OtherStateRequired)
        }
    }

    async fn handle_run_logo_system_asset(&mut self) -> Result<(), StateError> {
        if let State::RunLogoSystemAsset = &self.state {
            let lib = RunningLibrary::new(self.assets_dir.as_str(), SYSTEM_ARCADES_LOGO_PATH);
            let clients_events_buf: Arc<Mutex<Vec<ServerToSoTransitEvent>>> = Arc::new(Mutex::new(Vec::new()));
            // todo в усіх стейтах взяти /etc/sirin_arcades/arcades_resources/ logo/{game_name} папку, і відправити івентаи завантаження ресурсі з env({server}) + "/logo/intro.wav"
            for entry in WalkDir::new("/etc/sirin_arcades/arcades_resources/logo").into_iter().filter_map(|e| e.ok()) { // пропустить наприклад папки ті до яких не має доступу
                println!("{:?}", entry.path()); // todo somehow get data, write to array and send to users ;/
                // let so_to_client = SoToClient::LoadResource { data: [] };
                // for (_addr, write_conn) in self.clients_connections_write_halfs.iter_mut() {
                //     // якщо коннект обірвався то unwrap може видать паніку broken pipe, треба обробка поведінки розриву конекту що під час read що під час write
                //     unsafe { write_conn.write_all(std::slice::from_raw_parts(&so_to_client as *const SoToClient as *const u8, size_of::<SoToClient>())).await.unwrap(); }
                //     println!("sent so to client ");
                // }
            }

            {
                for (addr, read_half_for_this_id) in self.clients_connections_read_halfs
                    .lock()
                    .await.drain() {
                    let clients_events_buf_cloned = Arc::clone(&clients_events_buf);
                    tokio::spawn(async move {
                        let id = addr;
                        let mut read_half_for_this_id = read_half_for_this_id;

                        // todo якщо її стопнули вона має повернуть в self.clients_connections_read_halfs - addr, read_half_for_this_id

                        loop {
                            const CLIENT_TO_SERVER_EVENT_SIZE: usize = size_of::<ClientToServerEvent>();
                            let mut exact_event_buf = [0; CLIENT_TO_SERVER_EVENT_SIZE];
                            match read_half_for_this_id.read_exact(&mut exact_event_buf).await {
                                Ok(CLIENT_TO_SERVER_EVENT_SIZE) => {
                                    let client_to_server_event = unsafe { (exact_event_buf.as_ptr() as *const ClientToServerEvent).as_ref().unwrap() };
                                    println!("got event from {}: {:?} ", id, client_to_server_event);
                                    {
                                        let mut extended = [0u8; 32];

                                        match &addr {
                                            SocketAddr::V4(v4) => {
                                                extended[..4].copy_from_slice(&v4.ip().octets());
                                                //todo also port
                                                // extended[4..].copy_from_slice(&v4.port().to_be_bytes());
                                            }
                                            SocketAddr::V6(v6) => {
                                                extended[..16].copy_from_slice(&v6.ip().octets());
                                                //todo also port
                                                // extended[4..].copy_from_slice(&v6.port().to_be_bytes());
                                            }
                                        }
                                        clients_events_buf_cloned.lock().await.push(ServerToSoTransitEvent {
                                            client_id: extended,
                                            underlying_event: ServerToSoTransitEventType {
                                                client_event: *client_to_server_event
                                            },
                                        });
                                    }
                                }
                                _ => {
                                    // todo вбити асінк таску та перейти в минулий стейт
                                    panic!("eof"); // including connection closing
                                } // "operation encounters an "end of file" before completely filling the buffer"
                            }
                        }
                    });
                }
            }

            let mut so_to_server_transit_events = None;
            loop {
                println!("sending events from clients to so");
                let result = {
                    let copy =
                        {
                            let mut guard = clients_events_buf.lock().await;
                            guard.drain(..).collect::<Vec<_>>()
                        };

                    println!("{copy:?}");
                    unsafe { (lib.game_frame_fn)(copy.as_ptr(), copy.len()) }
                };
                if so_to_server_transit_events.is_none() {
                    so_to_server_transit_events = Some(result.first_element);
                }

                println!("beginning transit so -> client");

                // important: there is a necessity to handle each event (for at least freeing possible pointers passed to server)
                for event in unsafe { std::slice::from_raw_parts(result.first_element, result.length) } {
                    match event {
                        SoToServerTransitBack::ToClient(so_to_client) => {
                            for (_addr, write_conn) in self.clients_connections_write_halfs.iter_mut() {
                                // можливе покращення: настворить тасок і почекати їх виконання(?) можливо навіть на кожен івент замість про на кожен конект

                                // якщо коннект обірвався то unwrap може видать паніку broken pipe, треба обробка поведінки розриву конекту що під час read що під час write
                                unsafe { write_conn.write_all(std::slice::from_raw_parts(so_to_client as *const SoToClient as *const u8, size_of::<SoToClient>())).await.unwrap(); }
                                println!("sent so to client ");
                            }
                        }
                        SoToServerTransitBack::ToServer(SoToServerEvent::GoToState(_state)) => {
                            // idk
                        }
                        _ => {
                            panic!("you are punished");
                        }
                    }
                }
                println!("transit so -> client ended");
            }
            {
                let so_to_client = SoToClient::CleanResources;
                for (_addr, write_conn) in self.clients_connections_write_halfs.iter_mut() {
                    // якщо коннект обірвався то unwrap може видать паніку broken pipe, треба обробка поведінки розриву конекту що під час read що під час write
                    unsafe { write_conn.write_all(std::slice::from_raw_parts(&so_to_client as *const SoToClient as *const u8, size_of::<SoToClient>())).await.unwrap(); }
                    println!("sent so to client ");
                }
            }

            unsafe { free(so_to_server_transit_events.unwrap() as *mut c_void); }
            self.state = RunMenuSystemAsset;
            Ok(())
        } else {
            Err(StateError::OtherStateRequired)
        }
    }

    async fn handle_run_menu_system_asset(&mut self) -> Result<(), StateError> {
        if let State::RunMenuSystemAsset = &self.state {
            todo!();
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

    // todo game state
}

#[tokio::main]
async fn main() {
    let server_port = env::var("SIRIN_ARCADE_SERVER_PORT").expect("SIRIN_ARCADE_SERVER_PORT must be set");

    let client_port = env::var("SIRIN_ARCADE_CLIENT_PORT").expect("SIRIN_ARCADE_CLIENT_PORT must be set");

    let assets_dir = env::var("SIRIN_ARCADE_ASSETS_DIR").expect("SIRIN_ARCADE_ASSETS_DIR must be set");

    let supply_server_addr = env::var("SIRIN_SUPPLIER_ADDR").expect("SIRIN_SUPPLIER_ADDR must be set"); // http://127.0.0.1:5589/

    let mut server = GameServer::new(server_port, client_port, assets_dir, supply_server_addr).await;

    server.run_forever().await;
}
