use std::ffi::c_void;
use std::io::{Read, Write};
use std::net::{TcpStream, UdpSocket};
use std::process::exit;
use std::ptr::null_mut;
use crate::ap_types::{ClientToServerEvent, ServerToSoTransitEvent, SoToClient};

#[no_mangle]
pub extern "C" fn print_server_to_so_transit_event(event: &ServerToSoTransitEvent) {
    println!("{event:?}");
}

#[no_mangle]
pub extern "C" fn connect_to_bus(width: i32, height: i32) -> *mut c_void {
    println!("yeah its rust");
    let socket = match UdpSocket::bind("0.0.0.0:9877") {
        Ok(s) => { s }
        Err(_) => {
            return null_mut();
        }
    };

    let mut buf = [0u8; 4];
    let (received, sender) = {
        let mut res = socket.recv_from(&mut buf);
        while res.is_err() {
            res = socket.recv_from(&mut buf);
        };
        res.unwrap()
    };

    if buf[1] != ';' as u8 || buf[3] != ';' as u8 { //todo
        eprintln!("promises are broken. (format must be like 131;112;). BUT YOU GAVE THIS ABOMINATION {:?}", buf.as_slice());
        return null_mut();
    }
    if buf[0] > width as u8 || buf[2] > height as u8 { //todo u8 -> u32 // потенційно зберігти отримане для подальшого оффсету
        eprintln!("found server with bigger resolution than current screen. (buf[0]: {}, buf[2]: {}, width: {width}, height: {height})", buf[0], buf[2]);
        return null_mut();
    }

    if received != buf.len() {
        return null_mut()
    }

    println!("got a message: {}", String::from_utf8_lossy(&buf[..received]));

    let sender_addr = format!("{}:9876", sender.ip());
    let stream = match TcpStream::connect(sender_addr) {
        Ok(s) => s,
        Err(_) => {
            return null_mut()
        },
    };

    let boxed_stream = Box::new(stream);
    Box::into_raw(boxed_stream) as *mut c_void
}

#[no_mangle]
pub extern "C" fn cleanup_bus(bus: *mut c_void) {
    if bus.is_null() {
        panic!("here is your punishment, sus");
    }

    let bus = unsafe { Box::from_raw(bus as *mut TcpStream) };
    drop(bus);
}

#[no_mangle]
pub extern "C" fn make_handshake(bus: *mut c_void) -> i8 {
    if bus.is_null() {
        println!("here is your punishment, sus");
        exit(0);
    }

    let stream = unsafe { &mut *(bus as *mut TcpStream) };

    if let Err(_) = stream.write_all(&[0u8]) {
        return -1;
    }

    0
}

#[no_mangle]
pub extern "C" fn send_event(bus: *mut c_void, event: &ClientToServerEvent) -> i8 {
    if bus.is_null() {
        panic!("here is your punishment, sus");
    }

    let stream = unsafe { &mut *(bus as *mut TcpStream) };

    unsafe {
        if let Err(_) = stream.write_all(std::slice::from_raw_parts(event as *const ClientToServerEvent as *const u8, size_of::<ClientToServerEvent>())) {
            return -1;
        }
    }

    0
}

#[no_mangle]
pub extern "C" fn receive_event(bus: *mut c_void, event: &mut SoToClient, connection_closed: &mut bool) {
    if bus.is_null() {
        panic!("here is your punishment, sus");
    }

    let stream = unsafe { &mut *(bus as *mut TcpStream) };

    let mut buf = [0u8; size_of::<SoToClient>()];
    if let Err(_) = stream.read_exact(&mut buf) {
        *connection_closed = true;
        return;
    }
    *connection_closed = false;
    unsafe { std::ptr::copy_nonoverlapping(buf.as_ptr(), event as *mut SoToClient as *mut u8, size_of::<SoToClient>()); }
}
