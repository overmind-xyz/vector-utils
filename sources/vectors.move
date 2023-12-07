module overmind::vector_utils {
    use std::vector::{Self};
    #[test_only]
    use sui::test_utils::assert_eq;
    
    public fun initialise(size: u64, value: u8) : vector<u8> {
        let out = vector::empty<u8>();
        while (size > 0) {
            vector::push_back(&mut out, value);
            size = size - 1;
        };
        out
    }

    public fun pad(bytes: vector<u8>, to_length: u64, front:bool) : vector<u8> {
        assert!(to_length > 0, 0);
        let bytes_len = vector::length(&bytes);
        if (bytes_len < to_length) {
            let pad_by_number_of_bytes = to_length - bytes_len;
            let padding_vector = initialise(pad_by_number_of_bytes, 0);
            if (front) {
                vector::append(&mut padding_vector, bytes);
                padding_vector
            } else {
                vector::append(&mut bytes, padding_vector);
                bytes
            }
        } else {
            bytes
        }
    }

    fun from_bytes(bytes: vector<u8>) : u64 {
        let index = 0_u8;
        let out = 0_u64;

        while(index < 8) {
            let i = ((*vector::borrow(&bytes, (index as u64)) as u64) << index * 8);
            out = out + i;
            index = index + 1;
        };

        out
    }

    public fun from_le_bytes(bytes: vector<u8>) : u64 {
        bytes = pad(bytes, 8_u64, true);
        from_bytes(bytes)
    }

    public fun from_be_bytes(bytes: vector<u8>) : u64 {
        vector::reverse(&mut bytes);
        bytes = pad(bytes, 8_u64, false);
        from_bytes(bytes)
    }

    #[test]
    fun test_vector_stuff() {
        let v = initialise(4, 0);
        assert_eq(v, vector<u8> [
            0, 0, 0, 0
        ]);

        let v = initialise(4, 42);
        assert_eq(v, vector<u8> [
            42, 42, 42, 42
        ]);

        let v = pad(v, 8, true);
        assert_eq(v, vector<u8> [
            0, 0, 0, 0, 42, 42, 42, 42
        ]);

        let v = pad(v, 16, true);
        assert_eq(v, vector<u8> [
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 42, 42, 42, 42
        ]);

        let v = vector<u8> [4, 3, 2, 1];
        let number = from_le_bytes(v);
        assert_eq(72623859706101760, number);
        let v = vector<u8> [4, 3, 2, 1];
        let number = from_be_bytes(v);
        assert_eq(67305985, number);
    }
}
