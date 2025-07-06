Each module block that uses this module as its source will create a single launch template and a single auto scaling group.
It takes two object type variables, "launch_template" and "scaling_group".
The scaling group variable requires a list of availability zones "avilability_zones", as well as "desired_capacity", "min_size" and "max_size" of type number.
The module also requires a variable "region" of type string, representing the region the infrastructure will be created in.
There is an optional variable "tags" which takes a map of tags which will be applied to the scaling group and launch template.