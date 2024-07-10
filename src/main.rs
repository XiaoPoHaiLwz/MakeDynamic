use config;
use std::{env, fs, io, io::Write, process};
use walkdir::WalkDir;

struct Conf {
    super_list: Vec<String>,
    super_size: u64,
}

fn find_and_read_config(name: &str) -> Option<Conf> {
    let script_dir = env::current_dir().expect("Failed to get current directory");
    for entry in WalkDir::new(&script_dir) {
        let entry = entry.expect("Failed to read entry");
        if entry.file_type().is_dir() {
            let folder_name = entry.file_name().to_string_lossy();
            if folder_name == name {
                println!("Found matching device folder: {}", name);
                let conf_path = entry.path().join(format!("{}.conf", name));
                let settings = config::ConfigBuilder::<config::builder::DefaultState>::default()
                    .add_source(config::File::from(conf_path).format(config::FileFormat::Toml))
                    .build()
                    .unwrap();
                let super_list = settings
                    .get_array("settings.super_list")
                    .unwrap()
                    .into_iter()
                    .map(|v| v.into_string().unwrap())
                    .collect::<Vec<String>>();
                let super_size = settings.get_int("settings.super_size").unwrap() as u64;

                let conf = Conf {
                    super_list,
                    super_size,
                };

                return Some(conf);
            }
        }
    }
    None
}

fn get_file_size_in_kb(file_path: &str) -> io::Result<u64> {
    let metadata = fs::metadata(file_path)?;
    let size_in_bytes = metadata.len();
    let size_in_kb = size_in_bytes + 1000;
    Ok(size_in_kb as u64)
}

fn get_command_line_args() -> String {
    let args: Vec<String> = env::args().collect();
    if args.len() > 1 {
        args[1].clone()
    } else {
        panic!("Missing device name argument")
    }
}

fn remove_and_create_file(super_size: &u64) {
    let file_name = "dynamic_partitions_op_list_a";
    if fs::metadata(file_name).is_ok() {
        match fs::remove_file(file_name) {
            Ok(_) => println!("File '{}' deleted successfully.", file_name),
            Err(e) => {
                println!("Failed to delete file '{}': {}", file_name, e);
                process::exit(1); // 如果删除失败，退出程序
            }
        }
    }
    let mut file_path = fs::OpenOptions::new()
        .append(true)
        .create(true)
        .open(file_name)
        .expect("Failed to open file");

    file_path.write_all(
        format!(
            "remove_all_groups\n\nadd_group qti_dynamic_partitions_a {}\nadd_group qti_dynamic_partitions_b {}\n\n",
            super_size, super_size
        ).as_bytes()
    ).expect("Failed to write to file");
}

fn definition_dynamic(item: &str, size_kb: &[u64]) {
    let file_name = "dynamic_partitions_op_list_a";
    let mut file_path = fs::OpenOptions::new()
        .append(true)
        .create(true)
        .create(true)
        .open(file_name)
        .expect("Failed to open file");

    for i in item.lines() {
        for bytes in size_kb {
            file_path.write_all(format!("add {}_a qti_dynamic_partitions_a\nadd {}_b qti_dynamic_partitions_b\nresize {}_a {}\n\n",i,i,i,bytes).as_bytes()).expect("Failed to write to file");
        }
    }
}

fn main() {
    if nix::unistd::Uid::effective().is_root() {
        let args = get_command_line_args();
        if let Some(conf) = find_and_read_config(&args) {
            remove_and_create_file(&conf.super_size);

            let mut total_size_b: u64 = 0;

            for item in conf.super_list {
                let file_path = format!("image/{}.img", item);
                let size_kb = get_file_size_in_kb(&file_path).expect("Error getting file size");
                total_size_b += size_kb;
                if total_size_b > conf.super_size as u64 {
                    println!(
                        "请检查你的分区大小,他超过了你的super的大小：{}MB",
                        (total_size_b - conf.super_size) / 1024 / 1024
                    );
                    break;
                } else {
                    definition_dynamic(&item, &[size_kb]);
                }
            }
        }
    } else {
        panic!("Run it as root");
    }
}
