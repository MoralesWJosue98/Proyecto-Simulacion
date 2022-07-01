#-*-mode: TCL; coding: utf-8;-*-
::msgcat::mcset es normal normal
::msgcat::mcset es BC BC
::msgcat::mcset es {Int. system (SI)} {Sist. Int (SI)}
::msgcat::mcset es {Imperial system} {Sist. Imperial}
::msgcat::mcset es Length Longitud
::msgcat::mcset es Rotation Rotación
::msgcat::mcset es Mass Masa
::msgcat::mcset es Force Fuerza
::msgcat::mcset es Time Tiempo
::msgcat::mcset es ΔT ΔT
::msgcat::mcset es {General data} {Datos generales}
::msgcat::mcset es Analysis Análisis
::msgcat::mcset es {Problem type} {Tipo de problema}
::msgcat::mcset es {Beams & shells} {Vigas y láminas}
::msgcat::mcset es Beams Vigas
::msgcat::mcset es Shells Láminas
::msgcat::mcset es Solids Sólidos
::msgcat::mcset es {Plane strain} {Deformación plana}
::msgcat::mcset es {Plane stress} {Tensión plana}
::msgcat::mcset es Plates Placas
::msgcat::mcset es {'Plane stress' and 'Plates' are particular cases of 'Beams and shells'. Its only advantage is that they are faster. Input data and results are equal than 'Beams and shells'. 'Plane strain' substitutes the stress case for the strain case. In 'Plane strain', the Thickness of the shell is not considered.} {'Tensión plana' y 'Placas' son casos particulares de 'Vigas y Láminas'. Su única  ventaja es que son rápidos. El dato de entrada y los resultados son iguales que 'Vigas y Láminas'. En 'Deformación plana', sustituye el caso de tensión por el caso de deformación. En 'Deformación plana' el grosor de la lámina no se ha considerado.}
::msgcat::mcset es {Analysis type} {Tipo de análisis}
::msgcat::mcset es {Linear static} {Estático lineal}
::msgcat::mcset es {Linear dynamic} {Dinámico lineal}
::msgcat::mcset es {Non-Linear static} {Estático no-lineal}
::msgcat::mcset es {Non-Linear dynamic} {Dinámico no-lineal}
::msgcat::mcset es {Define the type of analysis to perform} {Defina el tipo de análisis a realizar}
::msgcat::mcset es {Beam P-Delta} {P-Delta en barras}
::msgcat::mcset es {When activated, P-Delta analysis is performed. This analysis considers the second order effects in the beams} {Cuando está activado, se realiza el análisis P-Delta. Este análisis considera los efectos de segundo orden en las vigas.}
::msgcat::mcset es General General
::msgcat::mcset es Type Tipo
::msgcat::mcset es {Modal analysis} {Análisis modal}
::msgcat::mcset es {Direct integration} {Integración directa}
::msgcat::mcset es {Spectrum analysis} {Análisis espectral}
::msgcat::mcset es {Choose the type of Dynamic Analysis that Ram-Series will perform} {Seleccione el tipo de Análisis Dinámico que Ram-Series realizará}
::msgcat::mcset es {Number of modes} {Número de modos}
::msgcat::mcset es {Choose the number of modes to consider in the Modal Analysis} {Seleccione el número de modosa considerar en el Análisis Modal.}
::msgcat::mcset es Δt Δt
::msgcat::mcset es {Time increment for the dynamic analysis} {Incremento del tiempo para el análisis dinámico}
::msgcat::mcset es {Number of steps} {Número de pasos}
::msgcat::mcset es {Number of steps of the dynamic analysis.
Total physical time will be Number_of_Steps X ΔT.} {Número de pasos del análisis dinámico. 
El tiempo físico total  será el número de pasos X ΔT.}
::msgcat::mcset es {Gamma (γ)} {Gamma (γ)}
::msgcat::mcset es {Parameter for the direct integration} {Parámetro para la integración directa}
::msgcat::mcset es {Beta (β)} {Beta (β)}
::msgcat::mcset es {Matrix storage} {Almacén de la matriz}
::msgcat::mcset es Lumped Concentrado
::msgcat::mcset es Consistent Consistente
::msgcat::mcset es {Choose the type of storage for the Mass and Damping Matrix. If Lumped Matrix storage is choose, the  part of the Damping Matrix related with the stiffness matrix is neglected  (αK=0).} {Escoja el tipo de almacenamiento para las matrices de masa y de amortiguamiento. Si se escoge matriz concentrada, la parte de la matriz de amortiguamiento relacionada con la matriz de rigidez se despreciara (αK=0).}
::msgcat::mcset es {Damping type} {Tipo de amortiguamiento}
::msgcat::mcset es {Modal damping} {Amortiguamiento modal}
::msgcat::mcset es {Rayleigh damping} {Amortiguamiento Rayleigh}
::msgcat::mcset es {Express the damping as a ratio of the critical damping ratio} {Exprese la amortiguación como un ratio del ratio de amortiguación crítica}
::msgcat::mcset es {Damping ratio} {Ratio de amortiguación}
::msgcat::mcset es αM αM
::msgcat::mcset es {Coefficient of the Mass Matrix in the Rayleigh Damping} {Coeficiente de la Masa de la Matriz en la Amortiguación Rayleigh}
::msgcat::mcset es αK αK
::msgcat::mcset es {Coefficient of the Stiffness Matrix in the Rayleigh Damping} {Coeficiente de la Rigidez de la Matriz en la Amortiguación Rayleigh}
::msgcat::mcset es {Seismic codes} {Códigos sísmicos}
::msgcat::mcset es {User defined spectrum} {Espectro de usuario definido}
::msgcat::mcset es {Initial conditions} {Condiciones iniciales}
::msgcat::mcset es None Ninguno
::msgcat::mcset es {Comb. load 1} {Carga comb. 1}
::msgcat::mcset es {User defined} {Def. usuario}
::msgcat::mcset es {Seismic data} {Datos sísmicos}
::msgcat::mcset es {Code type} {Tipo de código}
::msgcat::mcset es {94 Spain code} {Código español 94}
::msgcat::mcset es Other Otro
::msgcat::mcset es {Design acceleration} {Aceleración de diseño}
::msgcat::mcset es {Indicate de the design seismic acceleration proposed in the code} {Indique la aceleración del diseño sísmico propuesta en el código}
::msgcat::mcset es {Seismic Nx} {Nx sísmico}
::msgcat::mcset es {Indicate the component of the seismic in the x global direction} {Indique el componente del sísmico en la dirección de la global x}
::msgcat::mcset es {Seismic Ny} {Ny sísmico}
::msgcat::mcset es {Indicate the component of the seismic in the y global direction} {Indique el componente del sísmico en la dirección global de y}
::msgcat::mcset es {Seismic Nz} {Nz sísmico}
::msgcat::mcset es {Indicate the component of the seismic in the z global direction} {Indique el componente del sísmico en la dirección global de z}
::msgcat::mcset es {Soil coefficient} {Coeficiente del suelo}
::msgcat::mcset es {Soil coefficient defined in the code} {Coeficiente del suelo definido en el código}
::msgcat::mcset es {Contribution coefficient} {Coeficiente de contribución}
::msgcat::mcset es {Contribution coefficient defined in the code} {Coeficiente de contribución definido en el código}
::msgcat::mcset es Ductility Ductilidad
::msgcat::mcset es {Structure ductility defined in the code} {Ductilidad de la estructura definida en el código}
::msgcat::mcset es {U.D. spectrum} {Espectro de U.D.}
::msgcat::mcset es {Spectrum table} {Tabla de espectro}
::msgcat::mcset es {Function to multiply to the spectrum vector} {Función a multiplicar al vector de espectro}
::msgcat::mcset es {Spectrum Nx} {Nx espectro}
::msgcat::mcset es {Indicate the component of the spectrum in the x global direction} {Indique el componente del espectro de la dirección global de x}
::msgcat::mcset es {Spectrum Ny} {Ny espectro}
::msgcat::mcset es {Indicate the component of the spectrum in the y global direction} {Indique el componente del espectro en la dirección global de y}
::msgcat::mcset es {Spectrum Nz} {Nz espectro}
::msgcat::mcset es {Indicate the component of the spectrum in the z global direction} {Indique el componente del espectro en la dirección global de z}
::msgcat::mcset es ΔF ΔF
::msgcat::mcset es {Is the initial value of the incremental load factor or displacement factor. If the arc-length method is to be adopted
and the desired length,ΔLd, for the first increment is input as zero, then ΔP is automatically converted to a length} {Es el valor inicial del factor incremental de las cargas o del desplazamiento. Si se adopta el método de la longitu de arco
y la longitud deseada, ΔLd, para el primer incremento se introduce como cero, entonces  ΔP se convierte automàticamente a una longitud}
::msgcat::mcset es {Num increments} {Num incrementos}
::msgcat::mcset es {Is the desired number of increments} {Es el número deseado de incrementos}
::msgcat::mcset es {Automatic increment} {Incremento automático}
::msgcat::mcset es {If this parameter is set to 'Yes', automatic increment sizes are computed. 
Such automatic increments must be used with the arc-length method. 
If is set to 'No', equal increments of magnitude ΔP are adopted} {Si se activa el parámetro, se autocalcula el tamaño de los incrementos automáticos
Estos incrementos automáticos deben usarse con el método de longitud de arco
Si no se activa el parámetro, se adoptarán incrementos iguales de magnitud  ΔP}
::msgcat::mcset es Control Control
::msgcat::mcset es {Load control} {Control de cargas}
::msgcat::mcset es {Disp. control} {Control despl.}
::msgcat::mcset es {Arc-length control} {Control lonj. arco}
::msgcat::mcset es {Define the type of control for the non linear analysis.} {Defina el tipo de control para el análisis no lineal}
::msgcat::mcset es {Conv. tolerance} {Conv. tolerancia}
::msgcat::mcset es {Convergence tolerance factor.} {Factor de tolerancia de la convergencia}
::msgcat::mcset es {Iteration type} {Tipo iteración}
::msgcat::mcset es {Full N-R} {N-R completo}
::msgcat::mcset es {Modified N-R} {N-R modificado}
::msgcat::mcset es {Indicate if the full or modified Newton Raphson method is chosen.} {Se escoge entre el método de Newton Raphson entero o modificado}
::msgcat::mcset es {Max iterations} {Max iteraciones}
::msgcat::mcset es {Define the maximum number of iterations} {Define el máximo número de iteraciones}
::msgcat::mcset es Line-search {búsqueda lineal}
::msgcat::mcset es {Define if line search method is required} {Se escoje la activación de la búsqueda lineal}
::msgcat::mcset es Line-Search Búsqueda-lineal
::msgcat::mcset es {Ls loops} {Bucles BL}
::msgcat::mcset es {Define the maximum number of Line-Search loops.} {Defina el número máximo de bucles de búsqueda lineal}
::msgcat::mcset es {Ls toler} {Toler Bl}
::msgcat::mcset es {Ls min} {BL min}
::msgcat::mcset es {Ls max} {BL max}
::msgcat::mcset es {Amp max} {Amp max}
::msgcat::mcset es {Num iterations} {Num iteraciones}
::msgcat::mcset es {Number of iteration desired.} {Número de iteraciones deseado.}
::msgcat::mcset es {ΔP max} {ΔP max}
::msgcat::mcset es {Maximum load increment.} {Máximo incremento de carga.}
::msgcat::mcset es {ΔP min} {ΔP min}
::msgcat::mcset es {Minimum load increment.} {Mínimo incremento de carga.}
::msgcat::mcset es Arc-Length Longitud-arco
::msgcat::mcset es {ΔL d} {ΔL d}
::msgcat::mcset es {ΔL max} {ΔL max}
::msgcat::mcset es {Maximum length increment.} {Máximo incremento de longitud.}
::msgcat::mcset es {ΔL min} {ΔL min}
::msgcat::mcset es {Minimum length increment.} {Mínimo incremento de longitud.}
::msgcat::mcset es {Integr. method} {Método de integr.}
::msgcat::mcset es Implicit Implícito
::msgcat::mcset es Explicit Explícito
::msgcat::mcset es {Algorithm of temporal integration} {Algoritmo de integración temporal}
::msgcat::mcset es T0 T0
::msgcat::mcset es {Initial time for the dynamic analysis.} {tiempo inicial para el análisis dinámico.}
::msgcat::mcset es {Δt variation} {Variación Δt}
::msgcat::mcset es {Time increment variation for certain number of step.} {Variación del incremento temporal para un determinado número de pasos}
::msgcat::mcset es {Choose the type of storage for the Mass and Damping Matrix. If Lumped Matrix storage is choose, the  part of the Damping Matrix related with the stiffness matrix is neglected  (Alpha K=0).} {Seleccione el tip de almacenaje para la Masa y la Matriz de Amortiguación. Si se selecciona el almacén de Trozo de Matriz, la parte de la Amortiguacion de la Matriz relacionada con la matriz de rigidez se descuida (Alpha K=0).}
::msgcat::mcset es {Comb. load 1 data} {Carga comb. 1 datos}
::msgcat::mcset es {Only displacement} {Sólo desplazamiento}
::msgcat::mcset es {Displacement and load} {Desplazamiento y carga}
::msgcat::mcset es {Integration Data} {Datos de integración}
::msgcat::mcset es Damping Amortiguamiento
::msgcat::mcset es {Non linear} {No lineal}
::msgcat::mcset es {Initial N-R} {N-R inicial}
::msgcat::mcset es {Define the maximun number of iterations} {Defina el número máximo de iteraciones}
::msgcat::mcset es Units Unidades
::msgcat::mcset es {Mesh units} {Unidades de malla}
::msgcat::mcset es {Units system} {Sistema de unidades}
::msgcat::mcset es {Basic units} {Unidades básicas}
::msgcat::mcset es Gravity Gravedad
::msgcat::mcset es X X
::msgcat::mcset es Y Y
::msgcat::mcset es Z Z
::msgcat::mcset es Results Resultados
::msgcat::mcset es Granularity Granularidad
::msgcat::mcset es {Output maximums} {Volcado de máximos}
::msgcat::mcset es {When there are more than one loadcase, it is possible to output a special loadcase containing the maximums for beams. Option 'Automatic', outputs it only if there are steel sections. Option 'Always', output it if there are more than one loadcase.} {Cuando hay más de un caso de carga, es posible mostrar un caso de carga especial conteniendo el máximo para vigas. La opción 'Automatic' lo muestra sólo si existen secciones de acero. La opción 'Always', lo muestra sólo si existe más de un caso de carga.}
::msgcat::mcset es {Results axes} {Ejes de resultados}
::msgcat::mcset es Both Ambos
::msgcat::mcset es {Local axes} {Ejes locales}
::msgcat::mcset es {Main axes} {Ejes principales}
::msgcat::mcset es {Results for shells can be given in:
   Local Axes: the ones defined in the
     preprocess in the shell condition
   Main Axes: the main axes calculated for axial
     strengths and the main axes calculated
     for momentus} {Los resultados para las láminas se pueden dar en:
Ejes Locales: los que se definen en el 
preproceso en la condición de lámina
 Ejes Principales: los ejes principales calculados para fuerzas 
axiales y los ejes principales calculados
 para momentus}
::msgcat::mcset es {Output stresses} {Tensiones de salida}
::msgcat::mcset es {If this option is set, program will output the stresses and Von-Misses stress for the superior and inferior faces of the shell.} {Si se selecciona esta opción, se mostrarán las tensiones y la tensión de Von-Misses para las caras superior e inferior de la lámina.}
::msgcat::mcset es {Int 6Node elem} {6Nodo elem int}
::msgcat::mcset es {3-noded triangle shell elements are calculated internally as 6-noded elements.} {Los elementos de lámina de triángulo de 3 nodos se han calculado internamente como elementos de 6 nodos.}
::msgcat::mcset es {Smooth Results} {Resultados suaves}
::msgcat::mcset es {If Smooth results is set, strengths are smoothed by zones} {Si se selecciona resultados Suave, las fuerzas se suavizarán por zonas.}
::msgcat::mcset es Advanced Avanzado
::msgcat::mcset es Solver {Método de resolución}
::msgcat::mcset es {Equations solver} {Solver de ecuaciones}
::msgcat::mcset es {Solver type} {Tipo de solver}
::msgcat::mcset es Automatic Automático
::msgcat::mcset es SkyLine Skyline
::msgcat::mcset es Sparse Sparse
::msgcat::mcset es {Permmits to choose the solver to be used:
Atomatic: Runs a direct solver for small problems and an iterative for big ones.
SkyLine: Direct solver. It has no convergence problems but needs more RAM memory.
Sparse: Iterative solver. they take much less memory but may not converge. User can choose desired parameters.} {Permite selecconar el solver que se va a utilizar:
Automatic:Corre como solver directo para pequeños problemas y iterativo para los grandes.
Skyline: Solver directo. No tiene problemas de convergencia pero necesita más memoria RAM.
Sparse Solver iterativo. ocupa mucha menos memoria pero puede no converger. Los usuarios pueden seleccionar los parámetros deseados.}
::msgcat::mcset es {Solver tolerance} {Tolerancia del solver}
::msgcat::mcset es {Tolerance accepted to finish iterations} {Tolerancia aceptada para acabar iteraciones}
::msgcat::mcset es {Solver tolerance min} {Tolerancia min solver}
::msgcat::mcset es {If solver arrives to Max iterations, then this tolerance is used to accept or not the result.} {Si el solver llega a las iteraciones Máx, se acepta o no el resultado en función de esta tolerancia.}
::msgcat::mcset es {Solver max iterations} {Máximo de iteraciones del solver}
::msgcat::mcset es {Maximum number of iterations permmited to the solver.} {Número máximo de iteraciones permitidas al solver.}
::msgcat::mcset es {Eigen solver} {Eigen solver}
::msgcat::mcset es {Eigensolver max iterations} {Iteraciones max Eigensolver}
::msgcat::mcset es {Maximum number of iterations permmited to the eigensolver.} {Máximo número de iteraciones permitidas al eigensolver}
::msgcat::mcset es {Dynamic output} {Salida dinámica}
::msgcat::mcset es {Write displacements} {Escribir desplazamientos}
::msgcat::mcset es {Indicate if Displacements are required in the postprocess} {Indique si se requieren los desplazamientos  en el postproceso}
::msgcat::mcset es {Write rotations} {Escribir rotaciones}
::msgcat::mcset es {Indicate if Rotations are required in the postprocess} {Indicar si se requiere escribir las Rotaciones en el postproceso}
::msgcat::mcset es {Write velocities} {Escribir velocidades}
::msgcat::mcset es {Indicate if Velocities are required in the postprocess} {Indique si se requieren las velocidades en el postproceso}
::msgcat::mcset es {Write accelerations} {Escribir aceleraciones}
::msgcat::mcset es {Indicate if Accelerations are required in the postprocess} {Indique si se requieren las aceleraciones en el postproceso}
::msgcat::mcset es {Write strengths} {Escribir esfuerzos}
::msgcat::mcset es {Indicate if Strengths are required in the postprocess} {Indique si se requieren las fuerzas en el postproceso}
::msgcat::mcset es {Write reactions} {Escribir reacciones}
::msgcat::mcset es {Indicate if Reactions are required in the postprocess} {Indique si se requieren las reacciones en el postproceso}
::msgcat::mcset es {Write elem damage} {Escribir daño del elemento}
::msgcat::mcset es {Indicate if the elemental damage are required in the postprocess} {Indica si el daño elemental debe ser includo en el postproceso}
::msgcat::mcset es {Output step} {Paso de salida}
::msgcat::mcset es {Tdyn coupling} {Acoplamiento con Tdyn}
::msgcat::mcset es Filename Fichero
::msgcat::mcset es {Tdyn results file} {Fichero de resultados de Tdyn}
::msgcat::mcset es {Tdyn analysis name in results file} {Nombre de análisis de Tdyn en el fichero de resultados}
::msgcat::mcset es Result Resultado
::msgcat::mcset es {Tdyn result name in results file} {Nombre del resultado en el fichero de resultados de Tdyn}
::msgcat::mcset es {Detailed results} {Resultados detallados}
::msgcat::mcset es Constraints Restricciones
::msgcat::mcset es {Fixed constraints} {Restricciones fijas}
::msgcat::mcset es {Use this condition to prescribe the displacement or rotation of points.
Every marked flag will prescribe the movement for that degree of freedom.
The values fields permmit to set a prescribed displacement or rotation for that degree.
Units in International System for values are:
\t (m) for the displacements
\t(rad) for the rotations.} {Utilice esta condición para prescribir el desplazamiento ó rotación de puntos.
Cada bandera marcada prescribirá el movimiento para ese grado de libertad.\Los campos de valores permiten seleccionar un desplazamiento prescrito ó rotación para ese grado.
Los valores para las Unidades en el Sistema Internacional son:
\t(m) para los desplazamientos
\t(rad) para las rotaciones.}
::msgcat::mcset es Activation Activación
::msgcat::mcset es {X Constraint} {Restricción de X}
::msgcat::mcset es {Y Constraint} {Restricción de Y}
::msgcat::mcset es {Z Constraint} {Restricción de Z}
::msgcat::mcset es {θx Constraint} {Restricción θx}
::msgcat::mcset es {θy Constraint} {Restricción θy}
::msgcat::mcset es {θz Constraint} {Restricción θz}
::msgcat::mcset es Values Valores
::msgcat::mcset es {X value} {Valor X}
::msgcat::mcset es {Y value} {Valor Y}
::msgcat::mcset es {Z value} {Valor Z}
::msgcat::mcset es {θx value} {Valor θx}
::msgcat::mcset es {θy value} {Valor θy}
::msgcat::mcset es {θz value} {Valor θz}
::msgcat::mcset es {Elastic constraints} {Restricciones elásticas}
::msgcat::mcset es {X stiffness} {Rigidez X}
::msgcat::mcset es {Y stiffness} {Rigidez Y}
::msgcat::mcset es {Z stiffness} {Rigidez Z}
::msgcat::mcset es {θx stiffness} {Rigidez θx}
::msgcat::mcset es {θy stiffness} {Rigidez θy}
::msgcat::mcset es {θz stiffness} {Rigidez θz}
::msgcat::mcset es Connections Conexiones
::msgcat::mcset es {Disconnect all} {Desconectar todo}
::msgcat::mcset es {To disconnect some degrees in one point or line, select the degrees to disconnect. All beams or shell elements that contain that point will permmit the relative displacement or rotatation relative to any other element in that point} {Para desconectar algunos grados de libertad en un punto o línea, seleccione los grados a desconectar. Todas las vigas o elementos de lámina que contienen ese punto podrán desplazarse o rotar relativamente a cualquier otro elemento en dicho punto}
::msgcat::mcset es {Disconnect group} {Desconectar grupo}
::msgcat::mcset es Contacts Contactos
::msgcat::mcset es Penalty Penalización
::msgcat::mcset es {Dynamic conditions} {Condiciones dinámicas}
::msgcat::mcset es Masses Masas
::msgcat::mcset es {Mass x} {Masa x}
::msgcat::mcset es {Mass y} {Masa y}
::msgcat::mcset es {Mass z} {Masa z}
::msgcat::mcset es {Trasl mass} {Masa transl}
::msgcat::mcset es {M. inercia x} {M. inercia x}
::msgcat::mcset es {M. inercia y} {M. inercia y}
::msgcat::mcset es {M. inercia z} {M. inercia z}
::msgcat::mcset es {Surface mass} {Masa de superficie}
::msgcat::mcset es {Displacement x} {Desplazamiento x}
::msgcat::mcset es {Displacement y} {Desplazamiento y}
::msgcat::mcset es {Displacement z} {Desplazamiento z}
::msgcat::mcset es {Velocity x} {Velocidad x}
::msgcat::mcset es {Velocity y} {Velocidad y}
::msgcat::mcset es {Velocity z} {Velocidad z}
::msgcat::mcset es Properties Propiedades
::msgcat::mcset es {Rectangular section} {Sección rectangular}
::msgcat::mcset es {Width y} {Anchura y}
::msgcat::mcset es {Width z} {Anchura z}
::msgcat::mcset es Material Material
::msgcat::mcset es E E
::msgcat::mcset es {Young modulus} {Módulo de Young}
::msgcat::mcset es G G
::msgcat::mcset es {Torsion modulus} {Módulo de torsión}
::msgcat::mcset es {Specific weight} {Peso específico}
::msgcat::mcset es {Maximum stress} {Esfuerzo máximo}
::msgcat::mcset es {Generic section} {Sección genérica}
::msgcat::mcset es Data Datos
::msgcat::mcset es Area Área
::msgcat::mcset es {Inertia y} {Inercia y}
::msgcat::mcset es {Inertia z} {Inercia z}
::msgcat::mcset es J J
::msgcat::mcset es {Stress data} {Datos tensión}
::msgcat::mcset es Wy Wy
::msgcat::mcset es {'W y' is the resistance modulus (Wy=Iy/(z/2)) related to the Y' local axe.} {' W y ' es el módulo resistente (Wy=Iy/(z/2)) relacionado con el eje local de  Y '.}
::msgcat::mcset es Wz Wz
::msgcat::mcset es {'W z' is the resistance modulus (Wz=Iz/(y/2)) related to the Z' local axe.} {' W z ' es el módulo resistente (Wz=Iz/(y/2)) relacionado con el eje local  Z '.}
::msgcat::mcset es Aty Aty
::msgcat::mcset es {'Aty' is the shear area (tau_y=Qy/Aty).} {'Aty' es la área de cortante (tau_y=Qy/Aty).}
::msgcat::mcset es Atz Atz
::msgcat::mcset es {'Atz' is the shear area (tau_z=Qz/Atz).} {'Atz' es la área de cortante (tau_z=Qz/Atz).}
::msgcat::mcset es Name Nomb
::msgcat::mcset es {Predefined sections} {Secciones predefinidas}
::msgcat::mcset es {Sections library} {Biblioteca de secciones}
::msgcat::mcset es {Z axe position} {Posición del eje Z}
::msgcat::mcset es Edit Editar
::msgcat::mcset es {Naval stiffeners} {Rigidizadores navales}
::msgcat::mcset es {This property must be assigned to beams} {Esta propiedad debe asignarse a vigas}
::msgcat::mcset es {Isotropic shell} {Lámina isotrópica}
::msgcat::mcset es Thickness Espesor
::msgcat::mcset es {Poisson coeficient} {Coeficiente de Poisson}
::msgcat::mcset es {Anisotropic shell} {Lámina anisotrópica}
::msgcat::mcset es {Edit materials} {Editar materiales}
::msgcat::mcset es {Laminate shell} {Lámina de mat. compuesto}
::msgcat::mcset es {This property must be assigned to shells} {Esta propiedad debe asignarse a láminas}
::msgcat::mcset es {Number of layers} {Número de capas}
::msgcat::mcset es {Plasticity J2 shell} {Lamina plasticidad J2}
::msgcat::mcset es {Num layers} {Num capas}
::msgcat::mcset es {Isotropic solid} {Sólido isotrópico}
::msgcat::mcset es Materials Materiales
::msgcat::mcset es Steel Acero
::msgcat::mcset es {Elastic properties} {Propiedades elásticas}
::msgcat::mcset es {Specific weight of the material} {Peso específico del material}
::msgcat::mcset es {Maximum acceptable stress for this material} {Tensión máxima aceptable para el material}
::msgcat::mcset es Concrete Hormigón
::msgcat::mcset es Generic Genérico
::msgcat::mcset es Plasticity Plasticidad
::msgcat::mcset es {plasticity J2} {Plasticidad J2}
::msgcat::mcset es {Elastic limit} {Límite elástico}
::msgcat::mcset es {Isotropic hardening:} {Endurecimiento isotrópico:}
::msgcat::mcset es Linear Lineal
::msgcat::mcset es Exponential Exponencial
::msgcat::mcset es Linear+Exponential Lineal+Exponencial
::msgcat::mcset es {Linear hardening} {Endurecimiento lineal}
::msgcat::mcset es {Kinematic hardening:} {Endurecimiento cinemático:}
::msgcat::mcset es {Linear kinematic hardening} {Endurecimiento cinemático lineal}
::msgcat::mcset es Anisotropic Anisotrópico
::msgcat::mcset es {Anisotropic elastic prop} {Propiedad elástica Anisotrópica}
::msgcat::mcset es Ex Ex
::msgcat::mcset es {Young modulus in X direction} {Módulo de Young en dirección X}
::msgcat::mcset es Ey Ey
::msgcat::mcset es {Young modulus in Y direction} {Módulo de Young en dirección Y}
::msgcat::mcset es Nuxy Nuxy
::msgcat::mcset es {Poisson coefficient in XY} {Coeficiente de Poisson en XY}
::msgcat::mcset es Nuyx Nuyx
::msgcat::mcset es {Poisson coefficient in YX} {Coeficiente de Poisson en YX}
::msgcat::mcset es Gxy Gxy
::msgcat::mcset es Gxz Gxz
::msgcat::mcset es Gyz Gyz
::msgcat::mcset es Loadcases {Casos de carga}
::msgcat::mcset es {Combined LC} {CC combinados}
::msgcat::mcset es {Create a new loadcase for the loads} {Crear un nuevo caso de carga para las cargas}
::msgcat::mcset es {Punctual Load} {Carga Puntual}
::msgcat::mcset es {A static force and momentum applied to the selected points of the model. Units in International System for values are:
\t (N) for the forces.
\t (N*m) for the momentum.} {Una fuerza estática y un momento aplicados a los puntos seleccionados del modelo. Los valores para las Unidades en el Sistema Internacional son:
\t (N) para las fuerzas.
\t (N*m) para el momento.}
::msgcat::mcset es Factor Factor
::msgcat::mcset es {X force} {Fuerza X}
::msgcat::mcset es {Y force} {Fuerza Y}
::msgcat::mcset es {Z force} {Fuerza Z}
::msgcat::mcset es {Mx force} {Fuerza Mx}
::msgcat::mcset es {My force} {Fuerza My}
::msgcat::mcset es {Mz force} {Fuerza Mz}
::msgcat::mcset es {Pressure load} {Carga de presión}
::msgcat::mcset es {Load type} {Tipo de carga}
::msgcat::mcset es global global
::msgcat::mcset es {global projected} {global proyectada}
::msgcat::mcset es local local
::msgcat::mcset es {X pressure} {Presión en X}
::msgcat::mcset es {Y pressure} {Presión en Y}
::msgcat::mcset es {Z pressure} {Presión en Z}
::msgcat::mcset es {Mx pressure} {Presión en Mx}
::msgcat::mcset es {Self weight} {Peso propio}
::msgcat::mcset es {If this condition is applied to beams, a load is calculated and assigned, depending on the self-weight of the material, the area of the section and the direction of the gravity.} {Si esta condición es aplicada a las vigas, la carga se calcula y se asigna, dependiendo del peso propio del material, el área de la sección y la dirección de la gravedad.}
::msgcat::mcset es {Pressure Load} {Carga de presión}
::msgcat::mcset es {A static pressure load over the shell given in global axes. Units in International System for values are:
\t (N/m2) for the shell pressures.} {Una carga de presión estática sobre la lámina dada en los ejes globales. Los valores para las unidades en el Sistema Internacional son:
\t(N/m2) para las presiones de lámina.}
::msgcat::mcset es {Contour pressure} {Presión en el contorno}
::msgcat::mcset es {A static pressure load over the contour of the shell given in global axes or in user defined axes. Units in International System for values are:
\t (N/m) for the shell contour pressures.} {Una carga de la presión estática sobre el contorno de la lámina dada en los ejes globales ó en los ejes definidos por el usuario. Los valores de las unidades en el Sistema Internacional son:
\t(N/m) para las presiones del contorno de la lámina.}
::msgcat::mcset es {If this condition is applied to shells, a load is calculated and assigned, depending on the self-weight of the material, the thickness of the shell and the direction of the gravity.} {Si esta condición es aplicada a láminas, la carga se calcula y se asigna dependiendo del peso propio del material, el grosor de la lámina y la dirección de la gravedad.}
::msgcat::mcset es {A pressure load over the contour of the solid given in global axes. Units in International System for values are:
\t (N/m2) for the pressures.} {Una carga de la presión sobre el contorno del sólido dado en los ejes globales. Los valores de las unidades en el Sistema Internacional son:
\t(N/m2) para las presiones.}
::msgcat::mcset es {If this condition is applied to solids, a load is calculated and assigned, depending on the self-weight of the material, the volume of the solid and the direction of the gravity.} {Si esta condición se aplica a sólidos, una carga se calcula y se asigna, dependiendo del peso propio del material, el volumen del sólido y la dirección de la gravedad.}
::msgcat::mcset es Temperature Temperatura
::msgcat::mcset es {This condition considers the deformation supported by the solid when there is a uniform temperature change in all the solid.} {Esta condición considera la deformación soportada por el sólido cuando hay un cambio de temperatura uniforme en todo el sólido.}
::msgcat::mcset es α α
::msgcat::mcset es {Custom load} {Carga def usuario}
::msgcat::mcset es {A load defined by using the TCL extension language} {Una carga definida usando el lenguaje de extensión TCL}
::msgcat::mcset es {Units set} {Conjunto de unidades}
::msgcat::mcset es {TCL code} {Código TCL}
::msgcat::mcset es Displacements Desplazamientos
::msgcat::mcset es {Axial force} {Fuerza axial}
::msgcat::mcset es {Y' shear} {Cortante en Y'}
::msgcat::mcset es {Z' shear} {Cortante en Z'}
::msgcat::mcset es {Y' momentus} {Momento en Y'}
::msgcat::mcset es {Z' momentus} {Momento Z'}
::msgcat::mcset es Torsor Torsor
::msgcat::mcset es Shear Corte
::msgcat::mcset es Momentus Momento
::msgcat::mcset es {Main ax. force} {Fuerza axil ppal.}
::msgcat::mcset es N11 N11
::msgcat::mcset es N22 N22
::msgcat::mcset es {Main momentus} {Momento principal}
::msgcat::mcset es M11 M11
::msgcat::mcset es M22 M22
::msgcat::mcset es QM1 QM1
::msgcat::mcset es QM2 QM2
::msgcat::mcset es {Von Mises} {Von Mises}
::msgcat::mcset es Up Superior
::msgcat::mcset es Down Inferior
::msgcat::mcset es Stresses Tensiones
::msgcat::mcset es Reactions Reacciones
::msgcat::mcset es {M reactions} {Reacciones M}
::msgcat::mcset es Calculate Calcular
::msgcat::mcset es {Calculate remote} {Cálculo remoto}
::msgcat::mcset es Window Ventana
::msgcat::mcset es {Create results} {Crear resultados}
::msgcat::mcset es Help Ayuda
::msgcat::mcset es Action Acción
::msgcat::mcset es Define#C#menu Definir
::msgcat::mcset es Draw#C#menu Dibujar
::msgcat::mcset es {Draw all#C#menu} {Dibujar todo}
::msgcat::mcset es Delete#C#menu Borrar
::msgcat::mcset es {Delete all#C#menu} {Borrar todo}
::msgcat::mcset es {Start data} {Datos iniciales}
::msgcat::mcset es {Beams & Shells} {Vigas y láminas}
::msgcat::mcset es {Negative Y direction} {Dirección Y negativa}
::msgcat::mcset es {Negative Z direction} {Dirección Z negativa}
::msgcat::mcset es Another Otra
::msgcat::mcset es {Composite laminate} {Compuesto laminado}
::msgcat::mcset es combined combinado
::msgcat::mcset es maximum máximo
::msgcat::mcset es minimum mínimo
::msgcat::mcset es {maximum abs} {máximo abs}
::msgcat::mcset es {Create result} {Crear resultado}
::msgcat::mcset es Apply Aplicar
::msgcat::mcset es Close Cerrar
::msgcat::mcset es {create result} {crear resultado}
::msgcat::mcset es {Combination table} {Tabla de combinaciones}
::msgcat::mcset es ALL TODO
::msgcat::mcset es {Time step} {Paso de tiempo}
::msgcat::mcset es {User defined function} {Función definida por el usuario}
::msgcat::mcset es Add Añadir
::msgcat::mcset es Factor: Factor:
::msgcat::mcset es Component: Componente:
::msgcat::mcset es {New result} {Nuevo resultado}
::msgcat::mcset es {Create in} {Crear en}
::msgcat::mcset es {TCL expression} {Expresión TCL}
::msgcat::mcset es Scalar Escalar
::msgcat::mcset es {As 1st result} {Como primer resultado}
::msgcat::mcset es {Result will have the same components than the 1st result in the operation} {Los resultados tendrán las mismas componentes que el primer resultado en la operación}
::msgcat::mcset es {delete result} {borrar resultado}
::msgcat::mcset es {Delete results} {Borrar resultados}
::msgcat::mcset es {New name} {Nuevo nombre}
::msgcat::mcset es type tipo
::msgcat::mcset es {New name %d} {Nuevo nombre %d}
::msgcat::mcset es {Add result (factor 1.0)} {Añadir resultado (factor 1.0)}
::msgcat::mcset es {Add result (factor 0.0)} {Añadir resultado (factor 0.0)}
::msgcat::mcset es {Select all} {Seleccionar todo}
::msgcat::mcset es Copy Copiar
::msgcat::mcset es Paste Pegar
::msgcat::mcset es {Paste (substitute)} {Pegar (substituir)}
::msgcat::mcset es Delete Borrar
::msgcat::mcset es Clear Limpiar
::msgcat::mcset es {Are you sure to delete %d results?} {¿Está seguro de borrar %d resultados?}
::msgcat::mcset es {Results not OK} {Los resultados no son correctos}
::msgcat::mcset es {Results are not compatible} {Los resultados no son compatibles}
::msgcat::mcset es {There are no results in expression} {No hay resultados en la expresión}
::msgcat::mcset es {Expression is not correct (%s)} {La expresión no es correcta (%s)}
::msgcat::mcset es {New combined} {Nueva combinada}
::msgcat::mcset es {One combined per results} {Un combinado por resultado}
::msgcat::mcset es {Save steel section} {Guardar sección de acero}
::msgcat::mcset es {Enter steel section name:} {Introduzca el nombre de la sección de acero}
::msgcat::mcset es {Name must have 2 or more characters} {El nombre debe tener dos o más caracteres}
::msgcat::mcset es {There are no results to view} {No hay resultados para visualizar}
::msgcat::mcset es {Results cannot be viewed} {Los resultados no se pueden visualizar}
::msgcat::mcset es {Scale assigned sizes} {Escalar tamaños asignados}
::msgcat::mcset es OK Aceptar
::msgcat::mcset es Cancel Cancelar
::msgcat::mcset es {GiD res files} {Ficheros res GiD}
::msgcat::mcset es {All files} Todos
::msgcat::mcset es {Open GiD result file} {Abrir fichero resultados GiD}
::msgcat::mcset es {Yield criterion} {Criterio de agotamiento}
::msgcat::mcset es {Von Misses} {Von Misses}
::msgcat::mcset es Rankine Rankine
::msgcat::mcset es {Time steps} {Pasos de tiempo}
::msgcat::mcset es {A comma separated list of timesteps} {Una lista de pasos de tiempo separados por comas}
::msgcat::mcset es {Shear modulus} {Módulo de cortante}
::msgcat::mcset es {Stiffened shell} {Lámina reforzada}
::msgcat::mcset es Direction Dirección
::msgcat::mcset es Stiffener Refuerzo
::msgcat::mcset es Dm Dm
::msgcat::mcset es Df Df
::msgcat::mcset es Dmf Dmf
::msgcat::mcset es Dc Dc
::msgcat::mcset es Weight Peso
::msgcat::mcset es Max.Stress {Tensión máxima}
::msgcat::mcset es Wx Wx
::msgcat::mcset es Wt Wt
::msgcat::mcset es Loadcase {Caso de carga}
::msgcat::mcset es αx αx
::msgcat::mcset es {Wave load} {Cargas de ola}
::msgcat::mcset es Amplitude Amplitud
::msgcat::mcset es {Phase Angle} {ángulo de fase}
::msgcat::mcset es {Wave Length} {Longitud de onda}
::msgcat::mcset es {Wave Ship Length} {Longitud de onda del barco}
::msgcat::mcset es Meshing Mallar
::msgcat::mcset es Mesh Malla
::msgcat::mcset es {Composite naval stiffeners} {Rigidizadores navales mat compuestos}
::msgcat::mcset es {Stiffened Shells} {Láminas rigidizadas}
::msgcat::mcset es {Wave Loads} {Cargas de ola}
::msgcat::mcset es yes sí
::msgcat::mcset es no no
::msgcat::mcset es Perturbation Perturbación
::msgcat::mcset es Period Periodo
::msgcat::mcset es αy αy
::msgcat::mcset es {RamSeries is not compatible with this GiD version} {RamSeries no es compatible con esta versión de GiD}
::msgcat::mcset es {Cancel results} {Cancelar resultados}
::msgcat::mcset es {RamSeries is not compatible with this GiD version -a-} {RamSeries no es compatible con esta versión de GiD -a-}
::msgcat::mcset es {Entities report...} {Informe de entidades...}
::msgcat::mcset es {Dimension concrete} {Dimensionar hormigón}
::msgcat::mcset es {Steel report} {Informe sobre acero}
::msgcat::mcset es {Assign constraints} {Asignar restricciones}
::msgcat::mcset es {Draw properties} {Dibujar propiedades}
::msgcat::mcset es {Generate mesh} {Generar malla}
::msgcat::mcset es {View process info} {Ver información sobre el proceso}
::msgcat::mcset es {Cancel calculation process} {Cancelar el cálculo}
::msgcat::mcset es Draw Dibujar
::msgcat::mcset es More Más
::msgcat::mcset es {Default length units} {Unidades por defecto de longitud}
::msgcat::mcset es {Default force units} {Unidades por defecto de fuerza}
::msgcat::mcset es {Default mass units} {Unidades por defecto de masa}
::msgcat::mcset es {Custom data} {Implementación de Datos (Avanzado)}
::msgcat::mcset es {There are no results} {No hay resultados}
::msgcat::mcset es {Do you want to cancel results (size=%s Kb)?} {¿Desea usted cancelar los resultados (tamaño=%s KB)?}
::msgcat::mcset es {-Automatic alt-} {- alt automático-}
::msgcat::mcset es -Automatic- -Automático-
::msgcat::mcset es -GLOBAL- -GLOBAL-
::msgcat::mcset es {Local Axes} {Ejes Locales}
::msgcat::mcset es name nomb
::msgcat::mcset es Laminate Laminado
::msgcat::mcset es {Layers Data Entry} {Entrada de datos de capas}
::msgcat::mcset es {Entry is not a number} {El dato introducido no es un número}
::msgcat::mcset es {Specific Weight} {Peso específico}
::msgcat::mcset es {Failure Theory (Tsai-Wu)} {Teoría de Fallo (Tsai-Wu)}
::msgcat::mcset es {Calculate Security
Factor (PostProcess)} {Calcular el factor
de seguridad (Postproceso)}
::msgcat::mcset es {Allowable Stresses} {Tensión admisible}
::msgcat::mcset es {Allowable compression stress in direction 1} {Compresión admisible en la dirección 1}
::msgcat::mcset es {Allowable compression stress in direction 2} {Compresión admisible en la dirección 2}
::msgcat::mcset es {Allowable traction stress in direction 1} {Tracción admisible en la dirección 1}
::msgcat::mcset es {Allowable traccion stress in direction 2} {Tracción admisible en la dirección 2}
::msgcat::mcset es {Allowable shear stress} {Esfuerzo cortante admisible}
::msgcat::mcset es {Materials List} {Lista de materiales }
::msgcat::mcset es Thick Espesor
::msgcat::mcset es {Edit material} {Editar material}
::msgcat::mcset es {Delete material} {Borrar material}
::msgcat::mcset es Modify Modificar
::msgcat::mcset es Fiber-Resin Fibra-Resina
::msgcat::mcset es Edit-Data {Editar datos}
::msgcat::mcset es {Data Entry} {Entrada de datos}
::msgcat::mcset es {Fiber Angle} {Ángulo de la fibra}
::msgcat::mcset es Sequence Secuencia
::msgcat::mcset es User Usuario
::msgcat::mcset es {Fixed laminate sequence} {Secuencia de laminado predeterminada}
::msgcat::mcset es {Number of Sequences} {Número de secuencias}
::msgcat::mcset es {Laminate Composition} {Composición del laminado}
::msgcat::mcset es Angle Ángulo
::msgcat::mcset es Layers Capas
::msgcat::mcset es {Edit layer} {Editar capa}
::msgcat::mcset es {Delete layer} {Borrar capa}
::msgcat::mcset es {Select a material} {Seleccionar un material}
::msgcat::mcset es {Clear All} {Borrar todos}
::msgcat::mcset es {Visual Description} {Descripción visual}
::msgcat::mcset es {Another Material with this name already exists.
Please select a different name} {Ya existe otro material con este nombre. 
Por favor elija otro nombre}
::msgcat::mcset es {This material (%s) is used in laminate sequence
} {El material  (%s) se usa en la secuencia de laminado
}
::msgcat::mcset es {Are you sure you want to delete it?} {Seguro que quiere borrarlo?}
::msgcat::mcset es {Dialog window} {Ventana de diálogo}
::msgcat::mcset es {It is only possible edit one row at the same time} {Sólo es posible editar una fila a la vez}
::msgcat::mcset es Fiber Fibra
::msgcat::mcset es Resin Resina
::msgcat::mcset es {Young Modulus} {Módulo de Young}
::msgcat::mcset es Density Densidad
::msgcat::mcset es {Possion coef.} {Coef. de Poisson}
::msgcat::mcset es {Shear Modulus} {Módulo a cortante}
::msgcat::mcset es {Layer Type} {Tipo de capa}
::msgcat::mcset es {% Reinforcement} {% de Refuerzo}
::msgcat::mcset es {% of Reinforcement per unit mass.
It must be between 0 and 100} {% de refuerzo por unidad de masa, 
Debe estar entre 0 y 100}
::msgcat::mcset es {Vaccum Index} {Índice de vacío}
::msgcat::mcset es {It must be between 0 and 1} {Debe estar entre 0 y 1}
::msgcat::mcset es {Mass of Reinforcement} {Masa de refuerzo}
::msgcat::mcset es {Mass of R.} {Masa de R.}
::msgcat::mcset es {Vaccum Index must be between 0 and 1
} {El índice de vacío debe estar entre 0 y 1
}
::msgcat::mcset es {Poisson coef. for Resin has to be smaller than 0.5
} {El coeficiente de Poisson para la resina debe ser menor que 0.5
}
::msgcat::mcset es {Poisson coef. for Fiber has to be smaller than 0.5
} {El coeficiente de Poisson para la fibra debe ser menor que 0.5}
::msgcat::mcset es {%Reinforcement must be between 0 and 100
} {El % de refuerzo de refuerzo debe estar entre 0 y 100
}
::msgcat::mcset es {Please, check the consistency of the following values:
-%Reinforcement
-Vaccum Index
-Fiber Density
-Fiber Resin} {Por favor, compruebe los siguientes valores:
-%deRefuerzo
-Índice de vacío
Densidad de la fibra
-Fibra Resina}
::msgcat::mcset es {Number of sequences} {Número de secuencias}
::msgcat::mcset es {No sequence} {Sin secuencias}
::msgcat::mcset es Sym+Paste Simetría+Pegar
::msgcat::mcset es Create/Edit Crear/Editar
::msgcat::mcset es {Open a window to create or edit
a new laminate shell} {Abrir una ventana para crear o editar
una nueva lámina de materiales compuestos}
::msgcat::mcset es {Select a laminate shell before assigning condition} {Seleccione una lámina antes de asignar la condición}
::msgcat::mcset es Section Sección
::msgcat::mcset es {Laminate Name} {Nombre del laminado}
::msgcat::mcset es Laminates Laminados
::msgcat::mcset es {Base Width} {Ancho de la base}
::msgcat::mcset es {Spec. Weight} {Peso espec.}
::msgcat::mcset es {Please enter a name for the laminate} {Por favor, introduzca un nombre para el laminado}
::msgcat::mcset es {There is a laminate with the same name already. 
Please choose another name} {Ya existe otro material con este nombre.
Por favor elija otro nombre
 }
::msgcat::mcset es {Naval Stiffener} {Refuerzo naval}
::msgcat::mcset es {Open a window to create or to edit
a new naval composite material stiffener} {Abre iuna ventana para crear o editar
un refuerzo naval de materiales compuestos}
::msgcat::mcset es {Error, using an unknown magnitude for the problem units (%s)} {Error, se están usando una magnitud desconocida para las unidades del problema (%s)}
::msgcat::mcset es width: anchura:
::msgcat::mcset es Title: Título:
::msgcat::mcset es {Width Y:} {Anchura Y:}
::msgcat::mcset es {Width Z:} {Anchura Z:}
::msgcat::mcset es properties propiedades
::msgcat::mcset es {Beam Diagrams} {Diagramas de barras}
::msgcat::mcset es Deformed Deformada
::msgcat::mcset es {Beam displacements} {Desplazamientos en barras}
::msgcat::mcset es {Beam velocities} {Velocidades en barras}
::msgcat::mcset es {Beam accelerations} {Aceleraciones en barras}
::msgcat::mcset es {Stresses (Max)} {Tensiones (Max)}
::msgcat::mcset es {No results} {No hay resultados}
::msgcat::mcset es {Steel Resistance factor} {Factor de resistencia del acero}
::msgcat::mcset es Regions Regiones
::msgcat::mcset es Min Min
::msgcat::mcset es Max Max
::msgcat::mcset es Compose Componer
::msgcat::mcset es {Force x} {Fuerza x}
::msgcat::mcset es {Force y} {Fuerza y}
::msgcat::mcset es {Force z} {Fuerza z}
::msgcat::mcset es {Beam Local axes} {Ejes locales de viga}
::msgcat::mcset es {Resistance factor} {Factor de resistencia}
::msgcat::mcset es {Beam stresses (Max)} {Tensiones de viga (máximo)}
::msgcat::mcset es {Vibration modes} {Modos de vibración}
::msgcat::mcset es {Axial Force} {Fuerza Axial}
::msgcat::mcset es Integrate/graphs Integrales/gráficos
::msgcat::mcset es |Displacements| |Desplazamientos|
::msgcat::mcset es |Velocities| |Velocidades|
::msgcat::mcset es |Accelerations| |Acceleraciones|
::msgcat::mcset es {Main Ax. Force} {Ejes principales de fuerza}
::msgcat::mcset es {Main Momentus} {Momento Principal}
::msgcat::mcset es {N11 vector} {Vector N11}
::msgcat::mcset es {N22 vector} {Vector N22}
::msgcat::mcset es Disp_X Disp_X
::msgcat::mcset es Disp_Y Disp_Y
::msgcat::mcset es Disp_Z Disp_Z
::msgcat::mcset es Velocities Velocidades
::msgcat::mcset es Accelerations Aceleraciones
::msgcat::mcset es Accel_X Accel_X
::msgcat::mcset es Accel_Y Accel_Y
::msgcat::mcset es Accel_Z Accel_Z
::msgcat::mcset es {Stresses Up} {Presiones arriba}
::msgcat::mcset es {Stresses Down} {Presiones abajo}
::msgcat::mcset es {Von Misses Up} {Von Misses Arriba}
::msgcat::mcset es {Von Misses Down} {Von Misses Abajo}
::msgcat::mcset es Si-Stresses Presiones-Si
::msgcat::mcset es Sii-Stresses Presiones-Sii
::msgcat::mcset es Siii-Stresses Presiones-Siii
::msgcat::mcset es {Blast Pressure} {Presion de deflagración}
::msgcat::mcset es {Elemental Damage} {Daño elemental}
::msgcat::mcset es More... Más...
::msgcat::mcset es {There are no Results} {No hay resultados}
::msgcat::mcset es {No Results} {Sin resultados}
::msgcat::mcset es {The results '%s' does not exist in loadcase '%s'} {Los resultados ' %s' no existen en el caso de carga ' %s'}
::msgcat::mcset es {There is no report to visualize} {No se puede visualizar el informe}
::msgcat::mcset es Width Anchura
::msgcat::mcset es Loads Cargas
::msgcat::mcset es Title Título
::msgcat::mcset es To A
::msgcat::mcset es {Phase angle} {Angulo de fase}
