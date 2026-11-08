package random_pkg;

  `include "uvm_macros.svh"
  import uvm_pkg::*;

  class delay_item extends uvm_sequence_item;

  //class delay_generator extends uvm_object;
    // From: https://forums.accellera.org/topic/5206-good-technique-to-generate-a-random-delay/

    ///////////
    // Types //
    ///////////

    typedef enum {
      INSTANT,
      CHOPPY,
      BURSTY
    } traffic_type_e;

    typedef int unsigned delay_t;

    //////////////////////
    // Member Variables //
    //////////////////////

    `uvm_object_utils_begin(delay_generator)
      `uvm_field_enum(traffic_type_e, traffic_type, UVM_DEFAULT)
      `uvm_field_int(min_delay,                    UVM_DEFAULT | UVM_DEC)
      `uvm_field_int(max_delay,                    UVM_DEFAULT | UVM_DEC)
      `uvm_field_int(burst_on_min,                    UVM_DEFAULT | UVM_DEC)
      `uvm_field_int(burst_on_max,                    UVM_DEFAULT | UVM_DEC)
      `uvm_field_int(burst_off_min,                    UVM_DEFAULT | UVM_DEC)
      `uvm_field_int(burst_off_max,                    UVM_DEFAULT | UVM_DEC)
    `uvm_object_utils_end


    function new(string name = "delay_generator");
      super.new(name);
    endfunction

    rand traffic_type_e traffic_type;

    // delay limits between transactions
    rand delay_t min_delay, max_delay;

    // burst length limits
    rand delay_t burst_on_min, burst_on_max;
    rand delay_t burst_off_min, burst_off_max;

    /////////////////
    // constraints //
    /////////////////

    // min < max
    constraint delay_minmax_cnstr {
      min_delay <= max_delay;
      burst_on_min <= burst_on_max;
      burst_off_min <= burst_off_max;
    };

    int unsigned burst_on_count;
    int unsigned burst_off_count;

    /////////////
    // Methods //
    /////////////

    virtual function int unsigned get_rand();

      unique case (traffic_type)
        INSTANT: return 0;
        CHOPPY: return $urandom_range(min_delay, max_delay);
        BURSTY: begin
          // Randomize burst_on_count and burst_off_count.
          // Return `burst_off_count` -> delay this number of times of times
          //
          // Return 0 `burst_on_count` times. then, return `burst_off_count`
          // once.
          if (burst_on_count == 0) begin
            burst_on_count = $urandom_range(burst_on_min, burst_on_max);
            burst_off_count = $urandom_range(burst_off_min, burst_on_max);
            return burst_off_count;
          end
          burst_on_count -=1;
          return 0;
        end

      endcase

    endfunction

  endclass

endpackage
