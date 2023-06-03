const std = @import("std");

pub fn Queue(comptime T: type) type {
    return struct {
        const This = @This();

        const Node = struct {
            data: T,
            next: ?*Node,
        };

        gpa: std.mem.Allocator,
        first: ?*Node,
        last: ?*Node,

        pub fn init(gpa: std.mem.Allocator) This {
            return This{
                .gpa = gpa,
                .first = null,
                .last = null,
            };
        }

        pub fn enqueue(this: *This, el: T) !void {
            const last = try this.gpa.create(Node);
            last.* = .{
                .data = el,
                .next = null,
            };

            if (this.first == null) {
                this.first = last;
            }

            if (this.last) |oldLast| {
                oldLast.next = last;
            }

            this.last = last;

            std.log.info("\nqueueing: '{}, first: {}, last: {}'\n", .{ el, .{this.first}, .{this.last} });
        }

        pub fn dequeue(this: *This) ?T {
            const first = this.first orelse return null;
            defer this.gpa.destroy(first);

            this.first = first.next;

            if (first.next) |_| {} else {
                this.last = null;
            }

            return first.data;
        }

        pub fn destroy(this: *This) void {
            while (this.first) |_| {
                _ = this.dequeue();
            }
        }
    };
}
