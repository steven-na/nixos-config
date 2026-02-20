{ pkgs, ... }:
let
    btopWithCuda = pkgs.btop.override {
        cudaSupport = true;
    };
in
{
    programs.btop = {
        enable = true;
        package = btopWithCuda;
        settings = {
            theme_background = false;

            presets = "proc:0:default net:0:default";
            shown_boxes = "cpu mem";
            update_ms = 300;
            vim_keys = true;
            background_update = true;

            # cpu
            cpu_graph_upper = "total";
            cpu_single_graph = true;
            cpu_sensor = "Auto";
            check_temp = true;
            show_coretemp = false;
            show_gpu_info = "Auto"; # should only show my integrated graphics

            # gpu
            nvml_measure_pcie_speeds = false;
            rsmi_measure_pcie_speeds = true;

            # mem
            mem_graphs = true;
            show_disks = false;
            disks_filter = "/";
        };
    };
}
