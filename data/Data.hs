module Data where

import System.Random
import Control.Monad
import Data.List (nub)

grades = [1..9]
years = [2011..2014]
courses = ["COMP102", "COMP103", "COMP261", "COMP304", "COMP307", "COMP421", "COMP422",
           "SWEN102", "SWEN221", "SWEN222", "SWEN223", "SWEN224", "SWEN301", "SWEN302",
           "ENGR101", "ENGR201", "ENGR301", "ENGR302", "ENGR401", "ENGR402"]
studentIds = [1..100]

data Student = Student { sid :: Int, name :: String }

instance Show Student where
  show s = "INSERT INTO Student VALUES ("++ (show $ sid s) ++ ",\"" ++ (name s)++"\");"

data Grade = Grade { sgid :: Int, cname :: String, year :: Int, gpa :: Int }

instance Eq Grade where
  f == g = (sgid f == sgid g) && (cname f == cname g) && (year f == year g)

instance Show Grade where
  show g = "INSERT INTO Grades VALUES ("++ (show $ sgid g)
           ++",\""++(cname g)++"\","++(show $ year g)++","++(show $ gpa g)++");"

newName :: IO String
newName = liftM (take 10 . randomRs ('a', 'z')) newStdGen

newStudent :: Int -> IO Student
newStudent i = liftM (Student i) newName

newGrade :: IO Grade
newGrade = do
  g <- from grades
  y <- from years
  c <- from courses
  s <- from studentIds
  return $ Grade s c y g

from :: [a] -> IO a
from xs = liftM (xs !!) $ randomRIO (0, (length xs) - 1)

main :: IO ()
main = do
  grades <- replicateM 2000 newGrade
  students <- mapM newStudent studentIds
  let gradeStr = unlines . map show . nub $ grades
      studentStr = unlines . map show $ students
  writeFile "grades.sql" gradeStr
  writeFile "students.sql" studentStr
