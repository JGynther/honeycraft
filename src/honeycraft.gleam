import gleam/erlang/process
import gleam/io
import glisten.{Packet}
import gleam/option.{None}
import gleam/otp/actor
import protocol

fn handle_request(message, state, connection) {
  let assert Packet(message) = message
  let assert <<_, packet_id, _:bits>> = message

  case packet_id {
    0x00 -> protocol.handshake(connection)
    0x01 -> protocol.ping(message, connection)
    _ -> {
      io.debug(message)
      Ok(Nil)
    }
  }

  actor.continue(state)
}

const default_minecraft_port = 25_565

pub fn main() {
  let assert Ok(_) =
    glisten.handler(fn() { #(Nil, None) }, handle_request)
    |> glisten.serve(default_minecraft_port)

  process.sleep_forever()
}
