const std = @import("std");

pub fn Stack(comptime T: type) type {
    return struct {
        const This = @This();

        const Node = struct {
            data: T,
            next: ?*Node,
        };

        gpa: std.mem.Allocator,
        top: ?*Node,

        pub fn init(gpa: std.mem.Allocator) This {
            return This{
                .gpa = gpa,
                .top = null,
            };
        }

        pub fn push(this: *This, el: T) !void {
            const top = try this.gpa.create(Node);
            top.* = .{
                .data = el,
                .next = this.top,
            };

            this.top = top;
        }

        pub fn pop(this: *This) ?T {
            const top = this.top orelse return null;
            defer this.gpa.destroy(top);

            this.top = top.next;
            return top.data;
        }

        pub fn destroy(this: *This) void {
            while (this.top) |_| {
                _ = this.pop();
            }
        }
    };
}
