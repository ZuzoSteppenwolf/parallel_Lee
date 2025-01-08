from testing import assert_equal
from myUtil.Matrix import Matrix

# Test: Matrix
# Testet die Matrix Klasse
def test_Matrix():
    

    var mat = Matrix[Int, 5, 5]()
    mat[0, 0] = 1
    var num = mat[0, 0]
    mat[0, 1] = num
    assert_equal(mat.__str__(), "[\n\
[0, 0, 0, 0, 0]\n\
[0, 0, 0, 0, 0]\n\
[0, 0, 0, 0, 0]\n\
[0, 0, 0, 0, 0]\n\
[1, 1, 0, 0, 0]\n\
]")
    return