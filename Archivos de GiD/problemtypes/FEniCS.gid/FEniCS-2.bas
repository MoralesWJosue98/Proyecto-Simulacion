*realformat "%.7g"
<?xml version="1.0" encoding="UTF-8"?>

<dolfin xmlns:dolfin="http://www.fenics.org/dolfin/">
*if(nelem(tetrahedra,int)>0)
  <mesh celltype="tetrahedron" dim="3">
    <vertices size="*npoin">
*loop nodes
      <vertex index="*operation(nodesnum-1)" x="*nodescoord(1)" y="*nodescoord(2)" z="*nodescoord(3)"/>
*end nodes
    </vertices>
    <cells size="*nelem(tetrahedra)">
*set elems(tetrahedra)
*loop elems
      <tetrahedron index="*operation(elemsnum-1)" v0="*operation(elemsconec(1)-1)" v1="*operation(elemsconec(2)-1)" v2="*operation(elemsconec(3)-1)" v3="*operation(elemsconec(4)-1)"/>     
*end elems
    </cells>
    <domains>
*set cond domain_face_of_volume elems canrepeat
*if(condnumentities)
      <mesh_value_collection type="uint" dim="2" size="*condnumentities">
*loop elems onlyincond
        <value cell_index="*operation(elemsnum-1)" local_entity="*operation(condelemface-1)" value="*cond(id)" />
*end elems
      </mesh_value_collection>
*end if condnumentities
*set cond domain_body_of_volume elems canrepeat
*if(condnumentities)
      <mesh_value_collection type="uint" dim="3" size="*condnumentities">
*loop elems onlyincond
        <value cell_index="*operation(elemsnum-1)" local_entity="0" value="*cond(id)" />
*end elems
      </mesh_value_collection>
*end if condnumentities
    </domains>
  </mesh>
*end if
</dolfin>
