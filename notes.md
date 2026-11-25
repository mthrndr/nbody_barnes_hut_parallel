# High level overview

## Algorithm 

1. Input a csv of values
2. Initial setup:
    1. Create octree
    2. Calculate acceleration
3. Standard loop
    1. Update velocity by half a timestep
    2. Update position by a full timestep
    3. Create octree
    4. Calculate acceleration
    5. Update velocity by half a timestep

---

## Step breakdown

### Initial Loading
- Input has 7 columns (x, y, z, vx, vy, vz, m)
- Each value is a Double
- Each row is loaded into a custom data type: Body
- Each Body has 3 Triple data types and one mass Double:
    - Each triple data type holds 3 values (x,y,z) and represents either
      position velocity or acceleration. Acceleration set to 0 at beggining
- Each Body is loadded into a Vector
    - Vector: Contiguous in memory

### Creating the Octree

1. Go through the entire position vector to determine min and max x,y,z
2. Determine centerpoint
3. Determine initial width
    - Side is the max difference between min and max
    - It should be slightly larger so no point is on the boundary
4. Create the tree with foldl:
    - Helper function takes initial width, centerpoint, Vector of Bodies and
      returns an Octree
    - Recursive function that takes the Body's position triple, Body's mass,
      current node center and width, as well as the current Octree as input
      and returns the resulting Octree
    - Recursion passes center of node and width
    - Three types of nodes: Empty, Branch, Leaf
        - Empty has nothing
        - Branch has Mass, Center of Mass, List of Children
        - Leaf has Mass, and Position
    - Start with a single empty node
    - Every time you Process a new Body:
        - Empty (base case): Replace the node with a Leaf that holds it's
          mass and center of mass
        - Branch: Update mass and center of mass, then determine which child
          to go to and recurse. This is determined by comparing to center point
            -IE If you are +X,+Y,+Z compared to center, go to Leaf 0, +X,+Y,-Z go
            to Leaf 1, etc
        - Leaf: create a new Node, and put both Bodies into their Leaves as
          done in branch

### Traversing the Octree

Recurse passing down width and current body position, and returning accumulated
acceleration.

- Empty Node: Return a Triple with all 0s
- Leaf: Check that leaf is not the same as the body being considered. If it is
  return a triple with all 0s. If not calculate acceleration and return
- Branch: Given the Branch's stored center of mass and passed down width,
  determine if it's far enough to consider as a whole. If so calculate
  acceleration. If not recurse into it's children (leaves or empty)

Upon return update body's acceleration triple.

### Updating velocity and position

Relatively trivial
