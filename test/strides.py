import numpy as np
import asdf

array = np.array([[11,12,13], [21,22,23]], order='F')
file = asdf.AsdfFile({"array": array})
file.write_to("/tmp/strides.asdf")

file2 = asdf.open("/tmp/strides.asdf")
array2 = file2.tree["array"]

print("Original array:\n", array[:,:])
print("Recovered array:\n", array2[:,:])
