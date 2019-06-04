import LinearAlgebra
const la = LinearAlgebra

function apply_order!(robot::Robot, order::GoToAbsPosition)
    set_position!(robot, order.position)
    return
end

function apply_order!(robot::Robot, order::SetVelocity)
    vel = sqrt(order.x^2 + order.y^2)
    z = zero(robot.max_velocity)
    v = clamp(vel, z, robot.max_velocity)/vel
    set_velocity!(robot, v*order.x, v*order.y) # TODO: tooks too many memory
    return
end

function apply_order!(robot::Robot, order::NoOrder)
    return
end

function send_order!(robot::Robot, order::Order)
    robot.order = order
    return
end
