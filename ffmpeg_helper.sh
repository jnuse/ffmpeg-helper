#!/bin/bash  
  
# 定义颜色  
GREEN='\033[0;32m'  
YELLOW='\033[1;33m'  
RED='\033[0;31m'  
NC='\033[0m' # No Color  
  
# 定义普通提示信息  
print_normal_message() {  
    # clear
    echo -e "${GREEN}
***************************************************************
*** 聆听·彼岸 https://jnuse.github.io/                      ****
*** 其他命令需求 https://jnuse.github.io/20230415035347.html ***
***************************************************************

    ${NC}"  
}  

  
# 安装ffmpeg  
install_ffmpeg() {  
    echo -e "${GREEN}正在安装ffmpeg...${NC}"  
    bash <(curl https://gitee.com/baihu433/ffmpeg/raw/master/ffmpeg.sh)  
    echo -e "${GREEN}ffmpeg安装完成！${NC}"  
}  
  
# m4s转mp4  
convert_m4s_to_mp4() {  
    local dir=$(pwd)  
    local m4s_files=($(find "$dir" -maxdepth 1 -type f -name "*.m4s"))  
    local selected_files=()  
    local output_file="output.mp4"  
    local txt_list="m4s_list.txt"  
  
    # 创建一个空的txt文件用于ffmpeg concat  
    touch "$txt_list"  
  
    # 显示文件列表并让用户选择  
    while true; do  
        clear  
        echo "当前目录下的m4s文件："  
        for ((i=0; i<${#m4s_files[@]}; i++)); do  
            file="${m4s_files[$i]}"  
            index=$((i + 1)) # 计算索引，从1开始  
            if [[ " ${selected_files[*]} " == *" $file "* ]]; then  
                echo -e "${GREEN}${index}. ${file} (已选择)${NC}"  
            else  
                echo -e "${BLUE}${index}. ${file}${NC}"  
            fi  
        done  
        echo -e "${YELLOW}输入文件名在列表中的索引以选择，或输入q退出${NC}"  
        read -p "选择: " choice  
  
        # 检查用户输入  
        if [[ "$choice" == "q" ]]; then  
            break  
        elif ! [[ "$choice" =~ ^[1-9][0-9]*$ ]] || ((choice < 1 || choice > ${#m4s_files[@]})); then  
            echo -e "${RED}无效输入，请重新输入！${NC}"  
        else  
            file="${m4s_files[$((choice - 1))]}" # 转换用户输入的索引为数组索引  
            if [[ " ${selected_files[*]} " == *" $file "* ]]; then  
                echo -e "${RED}文件 '$file' 已选择，请重新选择！${NC}"  
            else  
                selected_files+=("$file")  
                echo "file '$file'" >> "$txt_list"  
            fi  
        fi  
    done  
  
    # 检查是否选择了文件  
    if [[ ${#selected_files[@]} -gt 0 ]]; then  
        local ffmpeg_cmd="ffmpeg -f concat -safe 0 -i \"$txt_list\" -c:v libx264 \"$output_file\""
        
        echo -e "${GREEN}开始转换选中的m4s文件到 ${output_file}...${NC}"  
        echo "$ffmpeg_cmd"  
        
        ffmpeg -f concat -safe 0 -i "$txt_list" -c:v libx264 "$output_file"  
        if [ $? -eq 0 ]; then  
            echo -e "${GREEN}转换完成！${NC}"  
        else  
            echo -e "${RED}转换过程中发生错误！${NC}"  
        fi  
        rm "$txt_list" # 删除临时txt文件  
    else  
        echo -e "${YELLOW}没有选择任何文件，退出转换。${NC}"  
    fi  
}
  
convert_one_ts_to_mp4() {  
    local ts_files=($(find "$(pwd)" -maxdepth 1 -type f -name "*.ts"))  
    local output_file="output.mp4"  
  
    # 检查是否有ts文件存在  
    if [[ ${#ts_files[@]} -eq 0 ]]; then  
        echo "当前目录下没有.ts文件。"  
        return 1  
    fi  
  
    # 显示所有ts文件并让用户选择  
    echo "请选择要转换的.ts文件："  
    for (( i=0; i<${#ts_files[@]}; i++ )); do  
        echo "$((i+1)). ${ts_files[$i]}"  
    done  
  
    read -p "输入文件编号：" user_input  
    file_index=$((user_input - 1))  
  
    # 检查用户输入是否有效  
    if [[ $file_index -ge 0 && $file_index -lt ${#ts_files[@]} ]]; then  
        selected_file="${ts_files[$file_index]}"  
    else  
        echo "无效的文件编号，退出转换。"  
        return 1  
    fi  
  
    # 执行转换  
    ffmpeg -i "$selected_file" -c:v libx264 -c:a aac "$output_file"  
  
    if [ $? -eq 0 ]; then  
        echo "文件 ${selected_file} 转换完成，输出为 ${output_file}"  
    else  
        echo "转换 ${selected_file} 时发生错误！"  
    fi  
}
  
convert_flv_to_mp4() {  
    local flv_files=($(find "$(pwd)" -maxdepth 1 -type f -name "*.flv"))  
    local output_file="output.mp4"  
  
    # 检查是否有flv文件存在  
    if [[ ${#flv_files[@]} -eq 0 ]]; then  
        echo "当前目录下没有.flv文件。"  
        return 1  
    fi  
  
    # 显示所有flv文件并让用户选择  
    echo "请选择要转换的.flv文件："  
    for (( i=0; i<${#flv_files[@]}; i++ )); do  
        echo "$((i+1)). ${flv_files[$i]}"  
    done  
  
    read -p "输入文件编号：" user_input  
    file_index=$((user_input - 1))  
  
    # 检查用户输入是否有效  
    if [[ $file_index -ge 0 && $file_index -lt ${#flv_files[@]} ]]; then  
        selected_file="${flv_files[$file_index]}"  
    else  
        echo "无效的文件编号，退出转换。"  
        return 1  
    fi  
  
    # 执行转换 
    # ffmpeg -i "$flv_file" -c:v libx264 -c:a aac "$output_file" 
    ffmpeg -i "$selected_file" -c:v libx264 -c:a aac "$output_file"  
  
    if [ $? -eq 0 ]; then  
        echo "文件 ${selected_file} 转换完成，输出为 ${output_file}"  
    else  
        echo "转换 ${selected_file} 时发生错误！"  
    fi  
}

convert_mkv_to_mp4() {  
    local mkv_files=($(find "$(pwd)" -maxdepth 1 -type f -name "*.mkv"))  
    local output_file="output.mp4"  
  
    # 检查是否有mkv文件存在  
    if [[ ${#mkv_files[@]} -eq 0 ]]; then  
        echo "当前目录下没有.mkv文件。"  
        return 1  
    fi  
  
    # 显示所有mkv文件并让用户选择  
    echo "请选择要转换的.mkv文件："  
    for (( i=0; i<${#mkv_files[@]}; i++ )); do  
        echo "$((i+1)). ${mkv_files[$i]}"  
    done  
  
    read -p "输入文件编号：" user_input  
    file_index=$((user_input - 1))  
  
    # 检查用户输入是否有效  
    if [[ $file_index -ge 0 && $file_index -lt ${#mkv_files[@]} ]]; then  
        selected_file="${mkv_files[$file_index]}"  
    else  
        echo "无效的文件编号，退出转换。"  
        return 1  
    fi  
  
    # 执行转换 
    # ffmpeg -i "$mkv_file" -c:v libx264 -c:a aac "$output_file" 
    ffmpeg -i "$selected_file" -c:v libx264 -c:a aac "$output_file"  
  
    if [ $? -eq 0 ]; then  
        echo "文件 ${selected_file} 转换完成，输出为 ${output_file}"  
    else  
        echo "转换 ${selected_file} 时发生错误！"  
    fi  
}

merge_ts_to_mp4() {  
    local ts_files=($(find "$(pwd)" -maxdepth 1 -type f -name "*.ts"))  
    local output_file="output.mp4"  
  
    if [[ ${#ts_files[@]} -eq 0 ]]; then  
        echo "当前目录下没有.ts文件。"  
        return 1  
    fi  
  
    ffmpeg -f concat -safe 0 -i <(for f in "${ts_files[@]}"; do echo "file '$f'"; done) -c copy "$output_file"  
  
    if [ $? -eq 0 ]; then  
        echo "文件合并完成，输出为 ${output_file}"  
    else  
        echo "文件合并时发生错误！"  
    fi  
}  
  
list_and_probe_files() {  
    local files=(*)  
    local num_files=${#files[@]}  
    local choice  
  
    # 检查当前目录下是否有文件  
    if [ $num_files -eq 0 ]; then  
        echo "当前目录下没有文件。"  
        return 1  
    fi  
  
    # 列出所有文件供用户选择  
    echo "请选择要查看信息的文件编号（1-${num_files}）："  
    for ((i=0; i<${num_files}; i++)); do  
        printf "%d: %s\n" $((i+1)) "${files[$i]}"  
    done  
  
    # 读取用户输入  
    read -p "请输入文件编号: " choice  
  
    # 检查用户输入是否有效  
    user_choice=$((choice-1))  
    if [ $user_choice -ge 0 ] && [ $user_choice -lt $num_files ]; then  
        selected_file="${files[$user_choice]}"  
    else  
        echo "无效的选择，请重新运行脚本。"  
        return 1  
    fi
  
    # 获取用户选择的文件  
    selected_file="${files[$(($choice-1))]}"  
  
    # 调用ffprobe查看文件信息  
    if command -v ffprobe >/dev/null 2>&1; then  
        ffprobe -i "$selected_file"  
    else  
        echo "ffprobe命令未找到，请确保已安装ffmpeg。"  
    fi  
}

# 定义菜单函数  
print_menu() {  
    # clear  
    echo "请选择操作："  
    echo "1. 安装ffmpeg"  
    echo "2. m4s转mp4"  
    echo "3. 一个ts转mp4"  
    echo "4. 一个flv转mp4"  
    echo "5. 一个mkv转mp4"  
    echo "6. 合并当前目录下的ts" 
    echo "7. 查看音视频文件信息" 
    echo "q. 退出"  
    read -p "请输入选项n/q): " choice  
}  
  
# 主循环  
while true; do  
    print_normal_message  
    print_menu  
  
    case $choice in  
        1)  
            install_ffmpeg  
            ;;  
        2)  
            convert_m4s_to_mp4  
            ;;  
        3)  
            convert_one_ts_to_mp4
            ;;  
        4)  
            convert_flv_to_mp4
            ;;  
        5)  
            convert_mkv_to_mp4
            ;;
        6)  
            merge_ts_to_mp4
            ;;
        7)  
            list_and_probe_files
            ;;
        q)  
            echo "退出脚本..."  
            exit 0  
            ;;  
        *)  
            echo -e "${RED}无效选项，请重新输入！${NC}"  
            ;;  
    esac  
done
