const std = @import("std");

extern fn _test() u32;
// export fn printStr(str: []u8) void{
//     std.debug.print("{s}\n",str);
// }
//

export fn _printu32(in: u32) void{
    std.debug.print("{d}\n", .{in});
}

export fn main() u32{
    const ret: u32 = _test();   
    std.log.info("program ran successfuly!", .{});
    return ret;
}

// zig quick tutorial
fn tut() void{
}
