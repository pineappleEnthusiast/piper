pip() {
    current_dir=$(pwd)  # curr dir

    command pip "$@"    # invoke og pip command

    command="$1"    # store command: install or uninstall
    shift
    package_info="$*"   # store flags, package name, package version


    # if the pip command was successful (exit code 0) and a package name is provided
    if [ $? -eq 0 ] && [ "$command" = "install" ] && [ -n "$package_info" ]; then
        package_info_clean=$(echo "$package_info" | sed -E 's/\s*(-+)[^[:space:]]+//g')
        trimmed_package_info="${package_info_clean#"${package_info_clean%%[![:space:]]*}"}"
        package_name=$(echo "$trimmed_package_info" | awk -F '==' '{print $1}')
        package_version=$(echo "$trimmed_package_info" | awk -F '==' '{print $2}')

        echo $package_name
        echo $package_version

        # if no version is provided, get the installed version using pip freeze
        if [ -z "$package_version" ]; then
            echo "no version provided"
            installed_version=$(pip freeze | grep "^${package_name}==")
            if [ -n "$installed_version" ]; then
                package_version=${installed_version#${package_name}==}
            fi
            echo $installed_version
        fi

        # check if requirements.txt exists in the current directory
        if [ -f "${current_dir}/requirements.txt" ]; then
            echo "requirements.txt exists"
            # check if the package is already listed in the requirements file
            if grep -q "^${package_name}==" "${current_dir}/requirements.txt"; then
                echo "package already in requirements.txt ${package_name}"
                # if the package is already listed, replace the line with the new version using sed
                sed -i '' "s/${package_name}.*/${package_name}==${package_version}/" "${current_dir}/requirements.txt"
            else
                # if the package is not listed, add it to requirements.txt
                echo "${package_name}==${package_version}" >> "${current_dir}/requirements.txt"
            fi
        else
            # if requirements.txt does not exist, create it and add the package name and version
            echo "${package_name}==${package_version}" > "${current_dir}/requirements.txt"
        fi
    elif [ "$command" = "uninstall" ] && [ -n "$package_info" ]; then
        # Handle pip uninstall by removing the package from requirements.txt
        package_name=$(echo "$package_info" | awk -F '==' '{print $1}')
        sed -i '' "/^${package_name}==/d" "${current_dir}/requirements.txt"
    fi
}