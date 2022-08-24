from ament_index_python.packages import get_package_share_directory

from launch import LaunchDescription, Substitution
from launch.actions import (DeclareLaunchArgument, GroupAction,
                            IncludeLaunchDescription, SetEnvironmentVariable)
from launch.conditions import IfCondition
from launch.launch_description_sources import PythonLaunchDescriptionSource
from launch.substitutions import PathJoinSubstitution, Command, FindExecutable, LaunchConfiguration
from launch_ros.actions import Node, PushRosNamespace
from launch_ros.descriptions import ParameterValue

def generate_launch_description():

    pkg_robot_description = get_package_share_directory('rb_theron_description')

    id_robot = LaunchConfiguration('id_robot')
    declare_id_robot_cmd = DeclareLaunchArgument(
        'id_robot',
        default_value='robot',
        description='ID-Robot')

    prefix = LaunchConfiguration('prefix')
    declare_prefix_cmd = DeclareLaunchArgument(
        'prefix',
        default_value=[id_robot, '_'],
        description='Prefix12')

    robot_description_pkg = LaunchConfiguration('robot_description_pkg')
    declare_robot_description_pkg_cmd = DeclareLaunchArgument(
        'robot_description_pkg',
        default_value=pkg_robot_description,
        description='Prefix12')

    robot_description_filename = LaunchConfiguration('robot_description_filename')
    declare_robot_description_filename_cmd = DeclareLaunchArgument(
        'robot_description_filename',
        default_value='rb_theron.urdf.xacro',
        description='Prefix12')

    robot_description_file_abs = LaunchConfiguration('robot_description_file_abs')
    declare_robot_description_file_abs_cmd = DeclareLaunchArgument(
        'robot_description_file_abs',
        default_value=[robot_description_pkg, '/robots/', robot_description_filename],
        description='Prefix12')


    robot_description_content = Command([
        PathJoinSubstitution([FindExecutable(name='xacro')]), ' ', robot_description_file_abs,
        ' prefix:=', prefix
    ])
    robot_description = {'robot_description': robot_description_content}
    
    description_cmd_group = GroupAction([
        PushRosNamespace(
            namespace=id_robot),

        Node(
            package="robot_state_publisher",
            executable="robot_state_publisher",
            output="both",
            parameters=[
                robot_description,
                {'publish_frequency': 50.0}],
        )
    ])

    ld = LaunchDescription([

        declare_id_robot_cmd,
        declare_prefix_cmd,
        declare_robot_description_pkg_cmd,
        declare_robot_description_filename_cmd,
        declare_robot_description_file_abs_cmd,

        description_cmd_group
    ])

    return ld
