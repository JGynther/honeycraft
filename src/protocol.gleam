import encode
import gleam/json
import gleam/bit_array
import gleam/bytes_builder
import glisten

pub fn generate_packet(packet_id: Int, response: json.Json) {
  let response =
    response
    |> json.to_string
    |> encode.encode_string

  let length = encode.encode_varint(bit_array.byte_size(response) + 1)

  bytes_builder.concat_bit_arrays([length, <<packet_id>>, response])
}

pub fn ping(message, connection) {
  let assert Ok(_) =
    glisten.send(connection, bytes_builder.from_bit_array(message))
}

pub fn handshake(connection) {
  let response =
    json.object([
      #(
        "version",
        json.object([
          #("name", json.string("1.20.4")),
          #("protocol", json.int(765)),
        ]),
      ),
      #(
        "players",
        json.object([
          #("max", json.int(100)),
          #("online", json.int(24)),
          #(
            "sample",
            json.array(
              [
                [
                  #("name", json.string("test")),
                  #("id", json.string("4566e69f-c907-48ee-8d71-d7ba5aa00d20")),
                ],
              ],
              of: json.object,
            ),
          ),
        ]),
      ),
      #("description", json.object([#("text", json.string("Hello world"))])),
      #("favicon", json.string("data:image/png;base64,<data>")),
      #("enforcesSecureChat", json.bool(True)),
      #("previewsChat", json.bool(True)),
    ])

  let builder = generate_packet(0x00, response)

  let assert Ok(_) = glisten.send(connection, builder)
}
