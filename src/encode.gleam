import gleam/bit_array
import gleam/int

pub fn encode_string(value: String) {
  let encoded = bit_array.from_string(value)
  let length =
    bit_array.byte_size(encoded)
    |> encode_varint

  bit_array.concat([length, encoded])
}

pub fn encode_varint(value: Int) {
  encode_varint_recursive(value, <<>>)
}

fn encode_varint_recursive(value: Int, encoded: BitArray) {
  case value {
    value if value <= 127 -> bit_array.append(encoded, to_byte(value))
    _ -> {
      let byte = int.bitwise_or(int.bitwise_and(value, 127), 128)
      encode_varint_recursive(
        int.bitwise_shift_right(value, 7),
        bit_array.append(encoded, to_byte(byte)),
      )
    }
  }
}

fn to_byte(value: Int) {
  <<value>>
}
