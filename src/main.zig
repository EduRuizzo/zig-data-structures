const std = @import("std");
const Stack = @import("stack.zig").Stack;
const Queue = @import("queue.zig").Queue;
const t = std.testing;

test "stack" {
    var iStack = Stack(i32).init(std.testing.allocator);
    defer iStack.destroy();

    try iStack.push(1);
    try iStack.push(2);
    try iStack.push(3);
    try iStack.push(4);
    try iStack.push(5);
    try iStack.push(6);

    try t.expectEqual(iStack.pop(), 6);
    try t.expectEqual(iStack.pop(), 5);
    try t.expectEqual(iStack.pop(), 4);
    try t.expectEqual(iStack.pop(), 3);
}

test "queue" {
    var iQueue = Queue(i32).init(std.testing.allocator);
    defer iQueue.destroy();

    try iQueue.enqueue(1);
    try iQueue.enqueue(2);
    try iQueue.enqueue(3);
    try iQueue.enqueue(4);
    try iQueue.enqueue(5);
    try iQueue.enqueue(6);

    try t.expectEqual(iQueue.dequeue(), 1);
    try t.expectEqual(iQueue.dequeue(), 2);
    try t.expectEqual(iQueue.dequeue(), 3);
    try t.expectEqual(iQueue.dequeue(), 4);

    try iQueue.enqueue(7);
    try iQueue.enqueue(8);

    try t.expectEqual(iQueue.dequeue(), 5);
    try t.expectEqual(iQueue.dequeue(), 6);
}
