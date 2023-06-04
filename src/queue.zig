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

            if (this.last) |oldLast| {
                oldLast.next = last;
            }

            this.last = last;

            if (this.first == null) {
                this.first = last;
            }

            //std.log.info("queueing: '{}, first: {}, last: {}'\n", .{ el, .{this.first}, .{this.last} });
        }

        pub fn dequeue(this: *This) ?T {
            const oldFirst = this.first orelse return null;
            defer this.gpa.destroy(oldFirst);

            // covers removing last element and setting this.first to null
            // because oldFirst.next would be null
            this.first = oldFirst.next;

            //  this.last = null when removing the last element
            if (oldFirst.next) |_| {} else {
                this.last = null;
            }

            return oldFirst.data;
        }

        pub fn destroy(this: *This) void {
            while (this.first) |_| {
                _ = this.dequeue();
            }
        }
    };
}
