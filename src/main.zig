const std = @import("std");
const Stack = @import("stack.zig").Stack;
const Queue = @import("queue.zig").Queue;
const BSTree = @import("bstree.zig").BSTree;
const AVLTree = @import("avltree.zig").AVLTree;
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

test "bst" {
    var bst = BSTree(i32).init(std.testing.allocator);
    defer bst.destroy();

    try bst.insert(50);
    try bst.insert(80);
    try bst.insert(30);
    try bst.insert(40);
    try bst.insert(70);
    try bst.insert(60);
    try bst.insert(75);
    try bst.insert(100);
    try bst.insert(90);
    try bst.insert(110);
    try bst.insert(120);
    try bst.insert(35);
    try bst.insert(45);

    var min = bst.minimum() orelse unreachable;
    var max = bst.maximum() orelse unreachable;

    try t.expectEqual(min.data, 30);
    try t.expectEqual(max.data, 120);

    try t.expect(bst.search(50) != null);
    try t.expect(bst.search(40) != null);
    try t.expect(bst.search(80) != null);
    try t.expect(bst.search(30) != null);
    try t.expect(bst.search(44) == null);
    bst.print();
    //     try bst.insert(100);
    //     try bst.insert(90);
    //     try bst.insert(0);

    try t.expect(bst.delete(120) != null);
    bst.print();

    try t.expect(bst.delete(30) != null);
    bst.print();

    try t.expect(bst.delete(80) != null);
    bst.print();

    min = bst.minimum() orelse unreachable;
    max = bst.maximum() orelse unreachable;

    try t.expectEqual(min.data, 35);
    try t.expectEqual(max.data, 110);
}

test "avl" {
    var avl = AVLTree(i32).init(std.testing.allocator);
    defer avl.destroy();

    _ = try avl.insert(10);
    _ = try avl.insert(20);
    _ = try avl.insert(30);
    _ = try avl.insert(40);
    _ = try avl.insert(50);
    _ = try avl.insert(25);
    _ = try avl.insert(5);
    _ = try avl.insert(7);

    // // The constructed AVL Tree would be
    // //        30
    // //       /  \
    // //     20   40
    // //    /  \     \
    // //   7   25    50
    // //  / \
    // // 5  10

    const min = avl.minimum() orelse unreachable;
    const max = avl.maximum() orelse unreachable;

    try t.expectEqual(min.data, 5);
    try t.expectEqual(max.data, 50);

    try t.expect(avl.search(10) != null);
    try t.expect(avl.search(20) != null);
    try t.expect(avl.search(25) != null);
    try t.expect(avl.search(30) != null);
    try t.expect(avl.search(40) != null);
    try t.expect(avl.search(50) != null);
    try t.expect(avl.search(44) == null);
    avl.print();

    _ = try avl.delete(40);
    // // The AVL Tree after delete would be
    // //         20
    // //       /    \
    // //      7      30
    // //    /  \     / \
    // //   5   10   25  50
    avl.print();
}
