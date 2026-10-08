// ============================================================================
// req_if.sv -- a valid/ready channel, as an interface
//
// A struct bundles DATA. An interface bundles a CONNECTION: the data plus the
// control signals that go the other way.
//
// Without an interface, every producer/consumer pair repeats this:
//
//     module producer (output logic valid_o, input logic ready_i,
//                      output req_t data_o);
//     module consumer (input  logic valid_i, output logic ready_o,
//                      input  req_t data_i);
//     // ...then six lines of .valid_o(...), .ready_i(...) at every hookup,
//     //    and the directions re-typed correctly every single time.
//
// With an interface it is one named thing, connected once:
//
//     req_if ch();
//     producer u_p (.clk_i, .rst_ni, .ch(ch));
//     consumer u_c (.clk_i, .rst_ni, .ch(ch));
//
// `modport` is what keeps this honest. It fixes the direction of every signal
// *per side*, so a producer physically cannot drive `ready` -- that is a
// compile error, not a debugging session.
// ============================================================================
interface req_if
  import ece180_pkg::*;
();

  logic valid;  // producer -> consumer: "I am offering an item this cycle"
  logic ready;  // consumer -> producer: "I can accept an item this cycle"
  req_t data;   // producer -> consumer: the payload

  // THE handshake rule, and the only one you need to memorise:
  //
  //     a transfer happens on a rising clock edge where valid && ready
  //
  // Both are just wires; neither side waits for the other. One extra rule
  // keeps it deadlock-free in real designs:
  //
  //     once a producer raises valid, it must hold valid and data steady
  //     until the transfer happens. It may NOT withdraw the offer.
  //
  // (The consumer has no such obligation: ready may drop at any time. If
  //  both sides waited for the other before committing, you would deadlock.)

  modport src (output valid, output data, input  ready);  // the producer side
  modport dst (input  valid, input  data, output ready);  // the consumer side

endinterface
