// початкова ідея
// client (TV) -> server
// server (TV + client_id) -> so (не забути що є два вида таких пакетів, створені клієнтом і створені сервером)
// so (TV) -> server/client (не забути що є пакети для клієнта або сервера які не перетинаються)
// read exact size of tag, then read exact size of that corresponding value

// +ивенти которие может клиент отправить серверу: нажатие кнопки(кнопка u8),

// +ивенти которие сервер может отправить сошке: все ивенти отправление клиентом + его ид,
// +server to so пакети: новие подключение(ид клиента),

// so отправляет серверу пакети, но они могут предназначаться для сервера либо клиента
// +для сервера: перейди в стейт(лоббі/меню/игра), запомнить_игру((строка),сохранить путь к сошнику)
// +для клиента: draw_pixel(x;y;pixel_t)

use std::fmt::{Debug, Formatter};

pub const SOCKET_ADDR_SIZE: usize = 32;

#[repr(C)]
#[derive(Copy, Clone, Debug)]
pub enum ClientToServerEvent {
    PressedButton { button: u8 },
    PressedButton22222222 { SOME_THING: u16 }, // other than PressedButton example (with not u8)
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
pub enum SoToClient {
    DrawPixel { x: u8, y: u8, pixel_t: pixel_t_rust_t }
}

#[repr(C)]
pub enum SoToServerTransitBack { // якщо для сервера то ніякого транзиту
    ToClient(SoToClient),
    ToServer(SoToServerEvent),
}

#[repr(C)]
pub struct SoToServerTransitBackArray {
    pub first_element: *const SoToServerTransitBack,
    pub length: usize,
}

// питання, якщо нічого передати сошці(жоден гравець нічого не прислав), відповідно сошка нічо теж не кине у відповідь?...

// що вже можна зробити з цими типами (якщо не галюциную):
// клієнт може використати сішну структуру ClientToServerEvent, поставити в ній тег PressedButton і потрібне значення
// надсилає всю структуру ClientToServerEvent (вказвівник на неї і sizeof структури)
// на стороні расту read_exact з буфером sizeof ClientToServerEvent, кастанути в нього

// далі сервер створює ServerToSoTranopt-level = 2 sitEvent з клієнт ід і ставить underlying_event отриманий івент
// записує його в найзвичайнісінький растовий Vec<ServerToSoTransitEvent> (звісно під мютексом, це той буфер)
// коли настає час, блокує буфер, викликає функцію game_frame передаючи взятий вказівник з вектора і його поточну довжину

// можна робити щоб сошка мала фн такого вигляду (*SoToServerTransitBack, size_t) game_frame(ServerToSoTransitEvent *first_event, size_t length)

// отже сошка отримала тупо масив (вказівник і скільки вперед), тип вона знає наперед ServerToSoTransitEvent
// вона бачить client_id і на основі цього може дізнатись який з елементів юніона потрібний
// вона також всередині бачить тег кожного пакета і на його основі може дізнатись потрібний юніон самого клієнт/сервер івента
// наївний погляд: нехай сошка при кожному виклику game_frame малочить по вказівник масив який поверне з функції з запамятовуваним розміром масиву
//      та має певний номер який останній незанятий елемент в цьому масиві
//      по мірі обробки вона створює івенти в тому буфері таким чином: записати івент по (вказівник+останній_незанятий) (реаллок якщо незанятий == розміру массиву і оновити змінну розміру)
//      останній_незанятий++
//
//      коли івенти закінчились передає серверу вказівник масиву і номер останньго незанятого елементу

// сервер отримав назад (ptr: *const SoToServerTransitBack, length: usize) і може все безпечно прочитати (бо типи repr C)
// виконати ті івенти які були для нього і слати далі кожному клієнту всі SoToClient

// клієнт читає (принаймні зараз цьому нічого не заважає) sizeof SoToClient, кастує, профіт

impl SoToServerTransitBack {
    #[no_mangle] // this funciton extists only for cbindgen generate header for SoToServerTransitBackArray and its recursive internals
    pub extern "C" fn useless2(button: u8) -> SoToServerTransitBackArray {
        unreachable!()
    }
}


#[derive(Clone, PartialEq, Copy)]
#[repr(C)]
pub struct pixel_t_rust_t { // always check if it is the same with c, conflicting types
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