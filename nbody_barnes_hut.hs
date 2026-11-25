import System.Environment (getArgs)
import Data.Vector (Vector)
import qualified Data.Vector as V (length, fromList)

data Triple = Triple
  { x :: !Double
  , y :: !Double
  , z :: !Double
  } deriving Show

data Body = Body
  { pos :: !Triple
  , vel :: !Triple
  , acc :: !Triple
  , mass :: !Double
  } deriving Show

data Octants a = Octants !a !a !a !a !a !a !a !a
  deriving (Show, Eq)

data Octree
  = Empty
  | Leaf
    { lMass :: !Double
    , lPos :: !Triple
    }
  | Branch
    { bMass :: !Double
    , bPos :: !Triple
    , octants :: !(Octants Octree)
    } deriving (Show, Eq)

-- Takes in the input of CSVs and turns them into a Vector of Bodies
parseBodies :: String -> Vector Body

-- Determines the center of an octant
-- Takes in the parent node's center Triple, width, and the octants idx
-- Returns the Octant's center Triple
subCenter :: Triple -> Double -> Int -> Triple

-- Determine starting center and max width
maxSize :: Vector Body -> (Triple, Double)

-- Determines which octant index a position triple goes into
-- Takes the body's position, the center, and returns an index
octantIndex :: Triple -> Triple -> Int

-- Updates one position within a set of Octants
-- Takes in the Octant index, modification function, input and output
modifyOctant :: Int -> (a -> a) -> Octants a -> Octants a
modifyOctant idx f (Octants o0 o1 o2 o3 o4 o5 o6 o7) = case idx of
  0 -> Octants (f o0) o1 o2 o3 o4 o5 o6 o7
  1 -> Octants o0 (f o1) o2 o3 o4 o5 o6 o7
  2 -> Octants o0 o1 (f o2) o3 o4 o5 o6 o7
  3 -> Octants o0 o1 o2 (f o3) o4 o5 o6 o7
  4 -> Octants o0 o1 o2 o3 (f o4) o5 o6 o7
  5 -> Octants o0 o1 o2 o3 o4 (f o5) o6 o7
  6 -> Octants o0 o1 o2 o3 o4 o5 (f o6) o7
  7 -> Octants o0 o1 o2 o3 o4 o5 o6 (f o7)
  _ -> error "index out of bounds"

-- Break a vector of bodies into the respective 8 octants
-- Takes in the starting center and the vector of bodies
-- Returns an Octant of those Vector Bodies in their respective Octant
subdivideBodiesToOctant :: Triple -> Vector Body -> Octants (Vector Body)

-- Divides the octree if depth is greater than 0 and recursively calls itself
-- If depth is 0 call octreeBuilderHelper on Vector of Bodies
octreeBuilderParallelized :: Int -> Triple -> Double -> Vector Body -> Octree

-- Starts the octree
-- Takes in the starting center and width as well as the Vector of Bodies, and
-- Returns the completed Octree
octreeBuilderHelper :: Triple -> Double -> Vector Body -> Octree

-- Recursively builds the octree
-- Takes in the current node's center and width, the Body being inserted's
-- position and mass and the current Octree
-- Returns the completed Octree
octreeBuilderRecursive :: Triple -> Double -> Triple -> Double -> Octree -> Octree

-- Traverses the octree to get acceleration on one body
-- Takes in the body's position, current node width and current octree
-- Returns acceleration Triple
octreeTraversal :: Triple -> Double -> Octree -> Triple

-- The parallelized function to call octree Traversal.
-- Takes in the size of the chunks, top node width, current octree
-- Returns updated Vector of Bodies
updateAcceleration :: Int -> Double -> Octree -> Vector Body -> Vector Body
-- Should be handled with parMap and rseq strategy


main :: IO ()
main = do
  args <- getArgs
  case args of
    [csvPath, depthStr, chunkStr] -> do
      let parallelBuilderDepth = read depthStr :: Int
          traversalChunkSize = read chunkStr :: Int
      contents <- readFile csvPath
      let bodies = parseBodies contents
          (center, width) = maxSize bodies
          tree = octreeBuilderHelper center width bodies
      putStrLn $ "Bodies: " ++ show (V.length bodies)
      putStrLn $ "parallelBuilderDepth: " ++ show parallelBuilderDepth
      putStrLn $ "traversalChunkSize: " ++ show traversalChunkSize
      putStrLn $ "Center: " ++ show center ++ ", width: " ++ show width
      print tree
    _ -> putStrLn "Usage: nbody_barnes_hut <bodies.csv> <parallelBuilderDepth> <traversalChunkSize>"
