<?xml version="1.0"?>
<dolfin xmlns:dolfin="http://fenicsproject.org">
  <parameters name="dolfin">
    <parameter key="allow_extrapolation" type="bool" value="*gendata(allow_extrapolation)" />
    <parameter key="exact_interpolation" type="bool" value="*gendata(exact_interpolation)" />
    <parameter key="graph_coloring_library" type="string" value="*gendata(graph_coloring_library)" />
    <parameter key="linear_algebra_backend" type="string" value="*gendata(linear_algebra_backend)" />
    <parameter key="mesh_partitioner" type="string" value="*gendata(mesh_partitioner)" />
    <parameter key="num_threads" type="int" value="*gendata(num_threads,int)" />
    <parameter key="optimize" type="bool" value="*gendata(optimize_dolfin)" />
    <parameter key="optimize_form" type="bool" value="*gendata(optimize_form)" />
    <parameter key="optimize_use_dofmap_cache" type="bool" value="*gendata(optimize_use_dofmap_cache)" />
    <parameter key="optimize_use_tensor_cache" type="bool" value="*gendata(optimize_use_tensor_cache)" />
    <parameter key="plot_filename_prefix" type="string" value="*gendata(plot_filename_prefix)" />
    <parameter key="refinement_algorithm" type="string" value="*gendata(refinement_algorithm)" />
    <parameter key="std_out_all_processes" type="bool" value="*gendata(std_out_all_processes)" />
    <parameter key="timer_prefix" type="string" value="*gendata(timer_prefix)" />
    <parameters name="form_compiler">
      <parameter key="cache_dir" type="string" value="*gendata(cache_dir)" />
      <parameter key="convert_exceptions_to_warnings" type="bool" value="*gendata(convert_exceptions_to_warnings)" />
      <parameter key="cpp_optimize" type="bool" value="*gendata(cpp_optimize)" />
      <parameter key="cpp_optimize_flags" type="string" value="*gendata(cpp_optimize_flags)" />
      <parameter key="epsilon" type="double" value="*gendata(epsilon,real)" />
      <parameter key="error_control" type="bool" value="*gendata(error_control)" />
      <parameter key="form_postfix" type="bool" value="*gendata(form_postfix)" />
      <parameter key="format" type="string" value="*gendata(format)" />
      <parameter key="log_level" type="int" value="*gendata(log_level,int)" />
      <parameter key="log_prefix" type="string" value="*gendata(log_prefix)" />
      <parameter key="name" type="string" value="*gendata(name)" />
      <parameter key="optimize" type="bool" value="*gendata(optimize_form_compiler)" />
      <parameter key="output_dir" type="string" value="*gendata(output_dir)" />
      <parameter key="precision" type="int" value="*gendata(precision,int)" />
      <parameter key="quadrature_degree" type="int" value="*gendata(quadrature_degree,int)" />
      <parameter key="quadrature_rule" type="string" value="*gendata(quadrature_rule)" />
      <parameter key="representation" type="string" value="*gendata(representation)" />
      <parameter key="split" type="bool" value="*gendata(split)" />
    </parameters>
    <parameters name="krylov_solver">
      <parameter key="absolute_tolerance" type="double" value="*gendata(absolute_tolerance,real)" />
      <parameter key="divergence_limit" type="double" value="*gendata(divergence_limit,real)" />
      <parameter key="error_on_nonconvergence" type="bool" value="*gendata(error_on_nonconvergence)" />
      <parameter key="maximum_iterations" type="int" value="*gendata(maximum_iterations,int)" />
      <parameter key="monitor_convergence" type="bool" value="*gendata(monitor_convergence)" />
      <parameter key="nonzero_initial_guess" type="bool" value="*gendata(nonzero_initial_guess)" />
      <parameter key="relative_tolerance" type="double" value="*gendata(relative_tolerance,real)" />
      <parameter key="report" type="bool" value="*gendata(report)" />
      <parameters name="gmres">
        <parameter key="restart" type="int" value="*gendata(gmres_restart,int)" />
      </parameters>
      <parameters name="preconditioner">
        <parameter key="report" type="bool" value="*gendata(preconditioner_report)" />
        <parameter key="reuse" type="bool" value="*gendata(preconditioner_reuse)" />
        <parameter key="same_nonzero_pattern" type="bool" value="*gendata(preconditioner_same_nonzero_pattern)" />
        <parameter key="shift_nonzero" type="double" value="*gendata(preconditioner_shift_nonzero,real)" />
        <parameters name="ilu">
          <parameter key="fill_level" type="int" value="*gendata(preconditioner_ilu_fill_level,int)" />
        </parameters>
        <parameters name="schwarz">
          <parameter key="overlap" type="int" value="*gendata(preconditioner_schwarz_overlap,int)" />
        </parameters>
      </parameters>
    </parameters>
    <parameters name="lu_solver">
      <parameter key="report" type="bool" value="*gendata(report)" />
      <parameter key="reuse_factorization" type="bool" value="*gendata(reuse_factorization)" />
      <parameter key="same_nonzero_pattern" type="bool" value="*gendata(same_nonzero_pattern)" />
    </parameters>
  </parameters>
</dolfin>
