const std = @import("std");

pub fn BSTree(comptime T: type) type {
    return struct {
        const This = @This();

        const Node = struct {
            data: T,
            left: ?*Node,
            right: ?*Node,
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

        // printNodes should print node data in order when doing inorder traversal
        pub fn printNodes(tree: ?*Node) void {
            if (tree) |tr| {
                printNodes(tr.left);
                std.debug.print("\tnode: {}\n", .{.{tr.data}});
                printNodes(tr.right);
            } else return;
        }

        pub fn insert(this: *This, el: T) !void {
            var current: *?*Node = &this.root;

            while (current.*) |curr| {
                if (el < curr.data) {
                    current = &curr.left;
                    continue;
                }

                if (el > curr.data) {
                    current = &curr.right;
                    continue;
                }
                return; // cannot repeat elements in a bs tree
            }

            const node = try this.gpa.create(Node);
            node.* = .{
                .data = el,
                .left = null,
                .right = null,
            };

            current.* = node;
            //std.debug.print("root: '{}'\n", .{.{this.root}});
        }

        fn successor(this: *This, el: T) ?*Node {
            _ = el;
            _ = this;
            // TODO inorder traversal
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
            var parentRef: *?*Node = &this.root;
            var found = false;

            while (parentRef.*) |curr| {
                if (el < curr.data) {
                    parentRef = &curr.left;
                    continue;
                }

                if (el > curr.data) {
                    parentRef = &curr.right;
                    continue;
                }

                found = true;
                break; // found element
            }

            if (found) {
                const no = parentRef.* orelse return null;

                defer this.gpa.destroy(no);

                // leaf delete
                if (no.left == null and no.right == null) {
                    parentRef.* = null;
                    return no;
                }

                // only one child deletes
                if (no.left == null) {
                    parentRef.* = no.right;
                    return no;
                }

                if (no.right == null) {
                    parentRef.* = no.left;
                    return no;
                }

                // both child delete
                const mn = minimumNode(no.right, no);
                const min = mn.minMax orelse return null;

                min.right = no.right;
                min.left = no.left;
                var parent = mn.parent orelse unreachable;
                parent.left = null;

                //std.debug.print("min: '{},parent: {}'\n", .{ .{min}, .{mn.parent} });
                parentRef.* = min;

                return min;
            }
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
