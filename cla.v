//`timescale 1ns / 1ns

/**
 * @param a first 1-bit input
 * @param b second 1-bit input
 * @param g whether a and b generate a carry
 * @param p whether a and b would propagate an incoming carry
 */
module gp1(input wire a, b,
           output wire g, p);
   assign g = a & b;
   assign p = a | b;
endmodule

/**
 * Computes aggregate generate/propagate signals over a 4-bit window.
 * @param gin incoming generate signals
 * @param pin incoming propagate signals
 * @param cin the incoming carry
 * @param gout whether these 4 bits internally would generate a carry-out (independent of cin)
 * @param pout whether these 4 bits internally would propagate an incoming carry from cin
 * @param cout the carry outs for the low-order 3 bits
 */
module gp4(input wire [3:0] gin, pin,
           input wire cin,
           output wire gout, pout,
           output wire [2:0] cout);

   // TODO: your code here
           assign cout[0] = gin[0] | (pin[0] & cin);
           assign cout[1] = gin[1] | (pin[1] & gin[0]) | (pin[1] & pin[0] & cin);
           assign cout[2] = gin[2] | (pin[2] & gin[1]) | (pin[2] & pin[1] & gin[0]) |  (pin[2] & pin[1] & pin[0] & cin);

           assign pout = &pin; 
           assign gout = gin[3] | (pin[3] & gin[2]) | 
                         (pin[3] & pin[2] & gin[1]) | 
                         (pin[3] & pin[2] & pin[1] & gin[0]);   
endmodule

/** Same as gp4 but for an 8-bit window instead */
module gp8(input wire [7:0] gin, pin,
           input wire cin,
           output wire gout, pout,
           output wire [6:0] cout);

   // TODO: your code here
           wire [1:0] g4, p4;
           wire [2:0] c_low, c_high;
           wire       carry4;
        
           // Lower 4 bits
           gp4 gp_low (
               .gin(gin[3:0]),
               .pin(pin[3:0]),
               .cin(cin),
               .gout(g4[0]),
               .pout(p4[0]),
               .cout(c_low));

         assign carry4 = g4[0] | (p4[0] & cin);

            // Upper 4 bits
            gp4 gp_high (
               .gin(gin[7:4]),
               .pin(pin[7:4]),
               .cin(carry4),
               .gout(g4[1]),
               .pout(p4[1]),
               .cout(c_high)
         );

         assign cout = {c_high, carry4, c_low};
         assign pout = p4[1] & p4[0];
         assign gout = g4[1] | (p4[1] & g4[0]);
endmodule

module cla
  (input wire [31:0]  a, b,
   input wire         cin,
   output wire [31:0] sum);

   // TODO: your code here
   wire [31:0] gin, pin;
   wire [3:0]  g8, p8;
   wire [30:0] c;
   wire [2:0]  carry8;

   genvar i;
   generate
      for (i = 0; i < 32; i = i + 1) begin : GP1
         gp1 gp1_inst (.a(a[i]), .b(b[i]), .g(gin[i]), .p(pin[i]));
      end
   endgenerate

   // 8-bit group blocks
   gp8 gp8_0 (.gin(gin[7:0]),   .pin(pin[7:0]),   .cin(cin),        .gout(g8[0]), .pout(p8[0]), .cout(c[6:0]));
   gp8 gp8_1 (.gin(gin[15:8]),  .pin(pin[15:8]),  .cin(carry8[0]),  .gout(g8[1]), .pout(p8[1]), .cout(c[14:8]));
   gp8 gp8_2 (.gin(gin[23:16]), .pin(pin[23:16]), .cin(carry8[1]),  .gout(g8[2]), .pout(p8[2]), .cout(c[22:16]));
   gp8 gp8_3 (.gin(gin[31:24]), .pin(pin[31:24]), .cin(carry8[2]),  .gout(g8[3]), .pout(p8[3]), .cout(c[30:24]));

   
   assign carry8[0] = g8[0] | (p8[0] & cin);
   assign carry8[1] = g8[1] | (p8[1] & carry8[0]);
   assign carry8[2] = g8[2] | (p8[2] & carry8[1]);

   assign c[7]  = carry8[0];
   assign c[15] = carry8[1];
   assign c[23] = carry8[2];
   
   assign sum[0] = a[0] ^ b[0] ^ cin;
   assign sum[31:1] = a[31:1] ^ b[31:1] ^ c[30:0];
endmodule
