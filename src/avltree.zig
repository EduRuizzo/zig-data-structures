const std = @import("std");

const Balance = enum {
    left,
    balanced,
    right,
};

pub fn AVLTree(comptime T: type) type {
    return struct {
        const This = @This();

        const Node = struct {
            data: T,
            left: ?*Node,
            right: ?*Node,
            height: i32,
        };

        const minMaxNode = struct {
            minMax: ?*Node,
            parent: ?*Node,
        };

        gpa: std.mem.Allocator,
        root: ?*Node,

        pub fn init(gpa: std.mem.Allocator) This {
            return This{
                .gpa = gpa,
                .root = null,
            };
        }

        pub fn print(this: *This) void {
            std.debug.print("Tree:\n", .{});
            printNodes(this.root);
        }

        // printNodes should print node data in pre-order when doing inorder traversal
        // print if unbalance detected
        pub fn printNodes(tree: ?*Node) void {
            if (tree) |tr| {
                std.debug.print("\tnode: data: {}, height:{}\n", .{ .{tr.data}, .{tr.height} });
                printNodes(tr.left);
                printNodes(tr.right);
                const bal = getBalance(tree);
                if (bal != Balance.balanced) {
                    std.debug.print("\nUnbalance detected!!!: {}, node:{}\n", .{ .{bal}, .{tr} });
                }
            } else return;
        }

        pub fn insert(this: *This, el: T) !void {
            try this.insertNode(&this.root, el);
        }

        pub fn insertNode(this: *This, tree: *?*Node, el: T) !void {
            if (tree.*) |node| {
                if (el < node.data) {
                    try this.insertNode(&node.left, el);
                    node.height = @max(height(node.left), height(node.right)) + 1;
                    tree.* = balance(node, el);
                    return;
                }
                if (el > node.data) {
                    try this.insertNode(&node.right, el);
                    node.height = @max(height(node.left), height(node.right)) + 1;
                    tree.* = balance(node, el);
                    return;
                }
                return; // if element in tree don´t insert
            } else {
                const node = try this.gpa.create(Node);
                node.* = .{
                    .data = el,
                    .left = null,
                    .right = null,
                    .height = 1,
                };
                tree.* = node;
            }
        }

        fn getBalance(tree: ?*Node) Balance {
            if (tree) |node| {
                if (node.left == null and node.right == null) {
                    return Balance.balanced;
                }

                const lheight = height(node.left);
                const rheight = height(node.right);

                if (lheight - rheight > 1) {
                    return Balance.left;
                }
                if (rheight - lheight > 1) {
                    return Balance.right;
                }
                return Balance.balanced;
            } else {
                return Balance.balanced;
            }
        }

        fn height(tree: ?*Node) i32 {
            if (tree) |node| {
                return node.height;
            } else {
                return 0;
            }
        }

        // returns new root
        fn balance(tree: *Node, el: T) *Node {
            const bal = getBalance(tree);
            if (bal == Balance.balanced) {
                return tree; // no balance required
            }

            if (bal == Balance.left) {
                // due to AVL characteristics right node has to exist
                const left = tree.left orelse unreachable;
                if (el < left.data) { // rotateRight
                    return rotateRight(tree);
                }
                // rotateLeftRight
                tree.left = rotateLeft(left);

                return rotateRight(tree);
            }

            if (bal == Balance.right) {
                // due to AVL characteristics right node has to exist
                const right = tree.right orelse unreachable;
                if (el > right.data) { // rotateLeft
                    const nr = rotateLeft(tree);
                    return nr;
                }
                //  rotateRightLeft
                tree.right = rotateRight(right);

                return rotateLeft(tree);
            }
            return tree;
        }

        fn rotateLeft(tree: *Node) *Node {
            // due to AVL characteristics right node has to exist
            const right = tree.right orelse unreachable;
            const left = right.left;

            right.left = tree;
            tree.right = left;

            tree.height = @max(height(tree.left), height(tree.right)) + 1;
            right.height = @max(height(right.left), height(right.right)) + 1;

            return right;
        }

        fn rotateRight(tree: *Node) *Node {
            // due to AVL characteristics left node has to exist
            const left = tree.left orelse unreachable;
            const right = left.right;

            left.right = tree;
            tree.left = right;

            tree.height = @max(height(tree.left), height(tree.right)) + 1;
            left.height = @max(height(left.left), height(left.right)) + 1;

            return left;
        }

        pub fn minimum(this: *This) ?*Node {
            return minimumNode(this.root, null).minMax;
        }

        fn minimumNode(tree: ?*Node, parent: ?*Node) minMaxNode {
            var mn = minMaxNode{
                .minMax = tree,
                .parent = parent,
            };

            while (mn.minMax) |current| {
                if (current.left) |_| {
                    mn.minMax = current.left;
                    mn.parent = current;
                } else {
                    break;
                }
            }

            return mn;
        }

        pub fn maximum(this: *This) ?*Node {
            return maximumNode(this.root, null).minMax;
        }

        fn maximumNode(tree: ?*Node, parent: ?*Node) minMaxNode {
            var mn = minMaxNode{
                .minMax = tree,
                .parent = parent,
            };

            while (mn.minMax) |current| {
                if (current.right) |_| {
                    mn.minMax = current.right;
                    mn.parent = current;
                } else {
                    break;
                }
            }

            return mn;
        }

        pub fn delete(this: *This, el: T) ?*Node {
            _ = el;
            _ = this;
            return null;
        }

        pub fn search(this: *This, el: T) ?*Node {
            return searchNode(this.root, el);
        }

        fn searchNode(node: ?*Node, el: T) ?*Node {
            var current: ?*Node = node;

            while (current) |curr| {
                if (el < curr.data) {
                    current = curr.left;
                    continue;
                }

                if (el > curr.data) {
                    current = curr.right;
                    continue;
                }

                return current; // found element
            }

            return null;
        }

        pub fn destroy(this: *This) void {
            this.destroyNodes(&this.root);
        }

        pub fn destroyNodes(this: *This, tree: *?*Node) void {
            if (tree.*) |root| {
                this.destroyNodes(&root.left);
                this.destroyNodes(&root.right);
                if (root.left == null and root.right == null) {
                    this.gpa.destroy(root);
                    tree.* = null;
                    return;
                }
                return;
            }
        }
    };
}
