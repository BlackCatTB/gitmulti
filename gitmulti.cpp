#include <iostream>
#include <fstream>
#include <cstdlib>
#include <cstdio>
#include <map>
#include <string>
#include <filesystem>

#ifdef _WIN32
    #include <windows.h>
    #define HOME_ENV "USERPROFILE"
#else
    #define HOME_ENV "HOME"
#endif

#include <iostream>
#include <fstream>
#include <string>
#include <cstdlib>
#include <unordered_map>

void promptToEditConfig(const std::string& configPath) {
#ifdef _WIN32
    std::string command = "notepad \"" + configPath + "\"";
    std::cout << "[*] Opening config in Notepad..." << std::endl;
    std::system(command.c_str());
#else
    std::ifstream file(configPath);
    std::string line;
    bool hasDefault = false;

    while (std::getline(file, line)) {
        if (line.find("default_url=git@uni.example.edu") != std::string::npos ||
            line.find("remote_name=uni") != std::string::npos) {
            hasDefault = true;
            break;
        }
    }

    if (hasDefault) {
        std::cout << "[!] Warning: Default config values are still present." << std::endl;
        std::cout << "    You should edit the config at: " << configPath << std::endl;
        std::cout << "    (e.g., using nano, vim, or your preferred editor)" << std::endl;

        std::string choice;
        std::cout << "    Open with nano now? [y/N]: ";
        std::getline(std::cin, choice);
        if (choice == "y" || choice == "Y") {
            std::string cmd = "nano \"" + configPath + "\"";
            std::system(cmd.c_str());
        }
    }
#endif
}

bool isDefaultConfig(const std::string& configPath) {
    std::ifstream file(configPath);
    if (!file) return true; // If the file can't be read, assume default

    std::unordered_map<std::string, std::string> config;
    std::string line;

    while (std::getline(file, line)) {
        auto pos = line.find('=');
        if (pos != std::string::npos) {
            std::string key = line.substr(0, pos);
            std::string val = line.substr(pos + 1);
            config[key] = val;
        }
    }

    return (
        config["remote_name"] == "uni" &&
        config["branch"] == "main" &&
        config["default_url"] == "git@uni.example.edu:your/repo.git"
    );
}



std::string getConfigPath() {
    const char* home = std::getenv(HOME_ENV);
    return std::string(home) + "/.gitmulti_config";
}

std::map<std::string, std::string> readConfig(const std::string& path) {
    std::map<std::string, std::string> config;
    std::ifstream file(path);
    std::string line;
    while (std::getline(file, line)) {
        auto sep = line.find('=');
        if (sep != std::string::npos) {
            config[line.substr(0, sep)] = line.substr(sep + 1);
        }
    }
    return config;
}

void createDefaultConfig(const std::string& path) {
    std::ofstream file(path);
    file << "remote_name=uni\n";
    file << "branch=main\n";
    file << "default_url=git@uni.example.edu:user/repo.git\n";
    file.close();
    std::cout << "[*] Created config at " << path << std::endl;
}

int main(int argc, char* argv[]) {
    std::string configPath = getConfigPath();

    if (!std::filesystem::exists(configPath)) {
        createDefaultConfig(configPath);
    }

    if (isDefaultConfig(configPath)) {
        promptToEditConfig(configPath);
    } else {
        std::cout << "Config has been customized. Proceeding with git operations..." << std::endl;
    }

    auto config = readConfig(configPath);
    std::string remoteName = config["remote_name"];
    std::string branch = config["branch"];
    std::string remoteURL = (argc > 1) ? argv[1] : config["default_url"];

    std::cout << "[*] Using remote '" << remoteName << "' with URL: " << remoteURL << std::endl;

    std::string addCmd = "git remote add " + remoteName + " " + remoteURL;
    int result = std::system(addCmd.c_str());

    if (result != 0) {
        std::cerr << "[!] Failed to add remote. It might already exist." << std::endl;
    }

    std::cout << "[*] Setting up push to both remotes..." << std::endl;

    // Get existing GitHub origin URL
    #ifdef _WIN32
        FILE* pipe = _popen("git remote get-url origin", "r");
    #else
        FILE* pipe = popen("git remote get-url origin", "r");
    #endif

    std::string githubURL;
    char buffer[256];

    if (pipe && fgets(buffer, sizeof(buffer), pipe)) {
        githubURL = buffer;
        githubURL.erase(githubURL.find_last_not_of(" \n\r\t") + 1);
    }
    #ifdef _WIN32
        if (pipe) _pclose(pipe);
    #else
        if (pipe) pclose(pipe);
    #endif

    if (!githubURL.empty()) {
        std::string addPushGitHub = "git remote set-url --add --push origin " + githubURL;
        std::system(addPushGitHub.c_str());
    }

    std::string setPushOrigin = "git remote set-url --add --push origin " + remoteURL;
    std::system(setPushOrigin.c_str());

    std::cout << "[✓] Done. Push with:\n    git push origin " << branch << std::endl;

    return 0;
}
