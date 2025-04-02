use std::ffi::c_char;
use std::fmt::{Debug, Formatter};

pub const SOCKET_ADDR_SIZE: usize = 32;

#[repr(C)]
#[derive(Copy, Clone, Debug)]
pub enum ClientToServerEvent {
    PressedButton { button: u8 },
}

#[repr(C)]
#[derive(Copy, Clone, Debug)]
pub enum ServerToSoEvent {
    NewConnectionId { id: u8 },
}

#[repr(C)]
pub union ServerToSoTransitEventType {
    pub server_event: ServerToSoEvent,
    pub client_event: ClientToServerEvent,
}

#[repr(C)]
pub struct ServerToSoTransitEvent {
    pub client_id: [u8; SOCKET_ADDR_SIZE],
    pub underlying_event: ServerToSoTransitEventType,
}

impl Debug for ServerToSoTransitEvent {
    fn fmt(&self, f: &mut Formatter<'_>) -> std::fmt::Result {
        if self.client_id == [0; 32] {
            writeln!(f, "{:?}", unsafe { self.underlying_event.server_event })
        } else {
            writeln!(f, "{:?}", unsafe { self.underlying_event.client_event })
        }
    }
}

#[repr(C)]
pub enum State {
    Lobby,
    Menu,
    Game,
}

#[repr(C)]
pub enum SoToServerEvent {
    GoToState(State),

    // because of this event passed from game to server, we can use pointers here, but rust must free them
    RememberGame { path: *const char },
}

#[repr(C)]
#[derive(Debug)]
pub enum SoToClient {
    DrawPixel {
        x: i32,
        y: i32,
        pixel_t: pixel_t_rust_t,
    },
    LoadResource {
        data: [c_char; 100],
    },
    PlayResource {
        data: [c_char; 100],
    },
    CleanResources,
}

#[repr(C)]
pub enum SoToServerTransitBack {
    ToClient(SoToClient),
    ToServer(SoToServerEvent),
}

unsafe impl Send for SoToServerTransitBack {}
unsafe impl Sync for SoToServerTransitBack {}

#[repr(C)]
pub struct SoToServerTransitBackArray {
    pub first_element: *const SoToServerTransitBack,
    pub length: usize,
}

// клієнт використовує сішну структуру ClientToServerEvent, ставить в ній тег PressedButton і потрібне значення
// надсилає всю структуру ClientToServerEvent (вказвівник на неї і sizeof структури)
// на стороні расту read_exact з буфером sizeof ClientToServerEvent і кастанути в нього

// далі сервер створює ServerToSoTransitEvent з клієнт ід і ставить underlying_event отриманий івент
// записує його в clients_events_buf: Arc<Mutex<Vec<ServerToSoTransitEvent>>>
// коли настає час, блокує буфер, викликає функцію game_frame передаючи взятий вказівник з вектора і його поточну довжину

// отже сошка отримала масив у вигляді вказівник і скільки в ньому елементів, тип вона знає наперед ServerToSoTransitEvent
// вона бачить client_id і на основі цього може дізнатись який з елементів юніона потрібний
// вона також всередині бачить тег кожного пакета і на його основі може дізнатись потрібний юніон самого клієнт/сервер івента
// сошка при кожному виклику game_frame повертає вказівник на масив івентів та його довжину
//      по мірі обробки вона заповнює масив івентами для сервера та клієнтів

// сервер отримав назад (ptr: *const SoToServerTransitBack, length: usize) і може все безпечно прочитати (бо типи repr C)
// виконує ті івенти які були для нього і шле далі кожному клієнту всі SoToClient

// клієнт читає sizeof SoToClient, кастує, профіт

impl SoToServerTransitBack {
    #[no_mangle] // this funciton extists only for cbindgen generate header for SoToServerTransitBackArray and its recursive internals
    pub extern "C" fn useless2() -> SoToServerTransitBackArray {
        unreachable!()
    }
}

#[derive(Clone, PartialEq, Copy, Debug)]
#[repr(C)]
pub struct pixel_t_rust_t {
    // always check if it is the same with c, conflicting types
    pub character: u8,
    pub color_pair_id: u8,
}

impl pixel_t_rust_t {
    #[no_mangle]
    pub extern "C" fn new(character: u8, color_pair_id: u8) -> pixel_t_rust_t {
        pixel_t_rust_t {
            character,
            color_pair_id,
        }
    }
}
