module multiplicar4
(
input [3:0]a,
input [3:0]b,
output [15:0]z
);

assign z[0]  = a[0]&b[0];
assign z[1]  = a[1]&b[0];
assign z[2]  = a[2]&b[0];
assign z[3]  = a[3]&b[0];
assign z[4]  = a[0]&b[1];
assign z[5]  = a[1]&b[1];
assign z[6]  = a[2]&b[1];
assign z[7]  = a[3]&b[1];
assign z[8]  = a[0]&b[2];
assign z[9]  = a[1]&b[2];
assign z[10] = a[2]&b[2];
assign z[11] = a[3]&b[2];
assign z[12] = a[0]&b[3];
assign z[13] = a[1]&b[3];
assign z[14] = a[2]&b[3];
assign z[15] = a[3]&b[3];

endmodule

module sum(
output cout,
output c,
input a,
input b,
input cin);

assign c= a^b^cin ;
assign cout = (a&b)|((a^b)&ci);
endmodule


module sum4(
input [3:0]a,
input [3:0]b,
input cin,
output [3:0]c,
output cout3);

wire cout0,cout1,cout2;

sum sm0 (.a(a[0]), .b(b[0]), .cin(cin), .c(c[0]), .cout(cout0) );
sum sm1 (.a(a[1]), .b(b[1]), .cin(cout0), .c(c[1]), .cout(cout1) );
sum sm2 (.a(a[2]), .b(b[2]), .cin(cout1), .c(c[2]), .cout(cout2) );
sum sm3 (.a(a[3]), .b(b[3]), .cin(cout2), .c(c[3]), .cout(cout3) );
endmodule