import Reactive
const re = Reactive

"""
Overwrites the `fpswhen_connect` function from Reactive defined in time.jl.
This allows to use a singnal object as rate instead of a single value.
"""
function re.fpswhen_connect(rate::re.Signal, switch, output, name)
    prev_time = time()
    outputref = WeakRef(output)
    switchref = WeakRef(switch)
    timer = Timer(identity, 0) # dummy timer to initialise
    function fpswhen_runner()
        # this function will run if switch gets a new value (i.e. is "active")
        # and if output is pushed to (assumed to be by the timer)
        if switch.value
            start_time = time()
            timer = re.setup_next_tick(outputref, switchref, start_time-prev_time, 1.0/re.value(rate))
            prev_time = start_time
        else
            re.close(timer)
        end
        switch.value
    end
    # the fpswhen_aux will start and stop the timer if switch's value updates, it'll
    # also setup the next tick once the first tick is pushed to output
    fpswhen_aux = re.Signal(switch.value, (switch, output); name="fpswhen runner switch: $(switch.name), output: $(output.name)")
    re.preserve(fpswhen_aux)
    re.add_action!(fpswhen_runner, fpswhen_aux)

    fpswhen_runner() # init
    # ensure timer stops when output node is garbage collected
    finalizer(_->re.close(timer), output)
end
