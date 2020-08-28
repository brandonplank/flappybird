#include <stdio.h>
#include <Foundation/Foundation.h>

void run_system(const char *cmd) {
    int status = system(cmd);
    if (WEXITSTATUS(status) != 0) {
        perror(cmd);
        exit(WEXITSTATUS(status));
    }
}

int main() {
    if (getuid() != 0) {
        setuid(0);
    }
    
    if (getgid() != 0) {
        setgid(0);
    }

    if (getuid() != 0) {
        printf("Can't set uid as 0.\n");
    }
    
    if (getgid() != 0) {
        printf("Can't set gid as 0.\n");
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:@"/private/var/mobile/Library/SplashBoard/Snapshots/org.brandonplank.flappybird" error:nil];
    [fileManager removeItemAtPath:@"/private/var/mobile/Library/Preferences/org.brandonplank.flappybird.plist" error:nil];
    run_system("uicache ")
    for (NSString *dataList in [fileManager contentsOfDirectoryAtPath:@"/private/var/mobile/Containers/Data/Application" error:nil]) {
        NSString *metadata = [NSString stringWithFormat:@"/private/var/mobile/Containers/Data/Application/%@/.com.apple.mobile_container_manager.metadata.plist", dataList];
        if ([fileManager fileExistsAtPath:metadata]) {
            NSDictionary *const dict = [NSDictionary dictionaryWithContentsOfFile:metadata];
            if (dict != nil) {
                if ([dict[@"MCMMetadataIdentifier"] isEqual:@"org.brandonplank.flappybird"]) {
                    if ([fileManager fileExistsAtPath:[NSString stringWithFormat:@"/private/var/mobile/Containers/Data/Application/%@/Library/Preferences/org.brandonplank.flappybird.plist", dataList]]) {
                        NSString *cmdToRun = [NSString stringWithFormat:@"rm -rf /private/var/mobile/Containers/Data/Application/%@", dataList];
                        run_system([cmdToRun UTF8String]);
                        printf("Ran clean script for data install!");
                    }
                }
            }
        }
    }

    return 0;
}
