from testing import assert_equal
from collections import Dict, List
from myUtil.Matrix import Matrix

# Test: Matrix
# Testet die Matrix Klasse
def test_Matrix_1():
    

    var mat = Matrix[Int](5, 5)
    mat[0, 0] = 1
    var num = mat[0, 0]
    mat[0, 1] = num
    for i in range(5):
        for j in range(5):
            if i == 0 and j == 0:
                assert_equal(mat[i, j], 1)
            elif i == 0 and j == 1:
                assert_equal(mat[i, j], 1)
            else:
                assert_equal(mat[i, j], 0)
 
    return

def test_Matrix_2():

    var mat = Matrix[List[Int]](1, 1)
    mat[0, 0] = List[Int](1, 2, 3)
    assert_equal(mat[0, 0], List[Int](1, 2, 3))
    mat[0, 0].append(4)
    assert_equal(mat[0, 0], List[Int](1, 2, 3, 4))
    return

def test_Matrix_3():

    var mat = Matrix[Dict[String, Int]](1, 1)
    mat[0, 0] = Dict[String, Int]()
    mat[0, 0]["test"] = 1
    assert_equal(mat[0, 0]["test"], 1)
    mat[0, 0]["test"] = 2
    assert_equal(mat[0, 0]["test"], 2)
    assert_equal("test" in mat[0, 0], True)
    return

def test_Matrix_4():

    var mat = Matrix[Dict[String, List[Int]]](1, 1)
    mat[0, 0] = Dict[String, List[Int]]()
    mat[0, 0]["test"] = List[Int](1, 2, 3)
    assert_equal(mat[0, 0]["test"], List[Int](1, 2, 3))
    mat[0, 0]["test"].append(4)
    assert_equal(mat[0, 0]["test"], List[Int](1, 2, 3, 4))
    assert_equal("test" in mat[0, 0], True)
    return
