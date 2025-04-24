
# gitmulti

`gitmulti` is a lightweight CLI utility written in C++ that helps you easily manage multiple `git remote` push targets — for example, pushing to both a personal GitHub repo and a university-hosted Git server at the same time.

---

## ✨ Features

- Adds a secondary remote (e.g., university Git server) based on folder or project name.
- Supports automatic push to both GitHub and a secondary remote.
- Creates a default configuration on first launch.
- Opens config in Notepad (on Windows) or offers to edit in nano (on Linux).
- Smart detection of existing remotes to avoid duplication.
- Windows installer with optional MinGW auto-setup.
- Unix installation script included.

---

## 🔧 Installation

### Windows

Run the provided PowerShell script to:

- Copy the binary to `Program Files\gitmulti\`
- Add it to your system `PATH`
- (Optionally) install MinGW for compiling

### Linux/macOS

Use the provided shell script:

```bash
sudo ./install-unix.sh
```

This will install the binary to `/usr/local/bin/gitmulti`.
And optionally install clang llvm for you on macos on request

---

## 🚀 Usage

From within any Git-tracked project folder:

```bash
gitmulti
```

You can also manually specify a custom remote URL:

```bash
gitmulti git@custom.git.server:user/project.git
```


## 🛠 Configuration

On first launch, a config file is created at:

- **Windows**: `C:\Users\<You>\.gitmulti_config`
- **Unix**: `~/.gitmulti_config`

Example:

```ini
remote_name=uni
branch=main
default_url=git@uni.example.edu:user/
```

The actual project name is inferred from the current folder name.

---

## 📝 License

See [LICENSE](LICENSE) for more info. MIT-licensed.

---

## 💡 Contributing

Pull requests are welcome! Feel free to open an issue or suggestion if you have ideas or improvements.

---

## 🙏 Acknowledgements

Built by [BlackCatTB](https://github.com/BlackCatTB) with love and caffeine ☕

