*realformat "%.7g"
<?xml version="1.0" encoding="UTF-8"?>

<dolfin xmlns:dolfin="http://www.fenics.org/dolfin/">
  <mesh_function>
*set cond mesh_function_face_of_volume elems canrepeat
*if(condnumentities)
    <mesh_value_collection type="uint" dim="2" size="*condnumentities">
*loop elems onlyincond
      <value cell_index="*operation(elemsnum-1)" local_entity="*operation(condelemface-1)" value="*cond(value)" />
*end elems
    </mesh_value_collection>
*end if condnumentities
*set cond mesh_function_body_of_volume elems canrepeat
*if(condnumentities)
    <mesh_value_collection type="uint" dim="3" size="*condnumentities">
*loop elems onlyincond
      <value cell_index="*operation(elemsnum-1)" local_entity="0" value="*cond(value)" />
*end elems
    </mesh_value_collection>
*end if condnumentities
  </mesh_function>  
</dolfin>
