use crate::ap_types::ServerToSoTransitEvent;

#[no_mangle]
pub extern "C" fn print_server_to_so_transit_event(event: &ServerToSoTransitEvent) {
    println!("{event:?}");
}
