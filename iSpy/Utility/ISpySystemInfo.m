//
//  ISpySystemInfo.m
//  iSpyDemo
//
//  Created by lslin on 15/11/30.
//  Copyright © 2015年 lessfun.com. All rights reserved.
//

#import "ISpySystemInfo.h"

// cpu & memory
#import <sys/stat.h>
#import <mach/mach.h>

// network
#include <arpa/inet.h>
#include <net/if.h>
#include <ifaddrs.h>
#include <net/if_dl.h>

@implementation ISpyMemoryInfo

@end


@implementation ISpyNetworkInfo

- (void)reset {
    self.wifiSent = 0;
    self.wiFiReceived = 0;
    self.wwanSent = 0;
    self.wwanReceived = 0;
}

- (void)updateWithNetworkInfo:(ISpyNetworkInfo *)netInfo {
    self.wifiSent = netInfo.wifiSent;
    self.wiFiReceived = netInfo.wiFiReceived;
    self.wwanSent = netInfo.wwanSent;
    self.wwanReceived = netInfo.wwanReceived;
}

@end


#pragma mark -

@implementation ISpySystemInfo

#pragma mark - CPU

// http://stackoverflow.com/questions/8223348/ios-get-cpu-usage-from-application?rq=1
+ (double)cpuUsage {
    kern_return_t kr;
    task_info_data_t tinfo;
    mach_msg_type_number_t task_info_count;
    
    task_info_count = TASK_INFO_MAX;
    kr = task_info(mach_task_self(), TASK_BASIC_INFO, (task_info_t)tinfo, &task_info_count);
    if (kr != KERN_SUCCESS) {
        return -1;
    }
    
    thread_array_t         thread_list;
    mach_msg_type_number_t thread_count;
    
    thread_info_data_t     thinfo;
    mach_msg_type_number_t thread_info_count;
    
    thread_basic_info_t basic_info_th;
    uint32_t stat_thread = 0; // Mach threads
    
    // get threads in the task
    kr = task_threads(mach_task_self(), &thread_list, &thread_count);
    if (kr != KERN_SUCCESS) {
        return -1;
    }
    if (thread_count > 0) {
        stat_thread += thread_count;
    }
    double totalCpu = 0;

    for (int i = 0; i < thread_count; ++ i) {
        thread_info_count = THREAD_INFO_MAX;
        kr = thread_info(thread_list[i], THREAD_BASIC_INFO,
                         (thread_info_t)thinfo, &thread_info_count);
        if (kr != KERN_SUCCESS) {
            return -1;
        }
        
        basic_info_th = (thread_basic_info_t)thinfo;
        
        if (!(basic_info_th->flags & TH_FLAGS_IDLE)) {
            totalCpu += basic_info_th->cpu_usage / (float)TH_USAGE_SCALE * 100.0;
        }
        
    } // for each thread
    
    kr = vm_deallocate(mach_task_self(), (vm_offset_t)thread_list, thread_count * sizeof(thread_t));
    assert(kr == KERN_SUCCESS);
    
    return totalCpu;
}

#pragma mark - Memory
// https://github.com/Shmoopi/iOS-System-Services/blob/master/System%20Services/Utilities/SSMemoryInfo.m

+ (ISpyMemoryInfo *)memoryInfo {
    static ISpyMemoryInfo *info = nil;
    if (!info) {
        info = [ISpyMemoryInfo new];
        info.total = [[NSProcessInfo processInfo] physicalMemory];
    }
    
    mach_port_t host_port = mach_host_self();
    mach_msg_type_number_t host_size = sizeof(vm_statistics_data_t) / sizeof(integer_t);
    vm_size_t pagesize;
    host_page_size(host_port, &pagesize);
    
    vm_statistics_data_t vm_stat;
    
    // Check for any system errors
    if (host_statistics(host_port, HOST_VM_INFO, (host_info_t)&vm_stat, &host_size) == KERN_SUCCESS) {
        // Memory statistics in B
        info.free = (vm_page_size * vm_stat.free_count);
        info.used = [self usedMemory];
        info.active = (vm_stat.active_count * pagesize);
        info.inactive = (vm_stat.inactive_count * pagesize);
        info.wired = (vm_stat.wire_count * pagesize);
        info.purgable = (vm_stat.purgeable_count * pagesize);
    }
    
    return info;
}

// http://stackoverflow.com/questions/7989864/watching-memory-usage-in-ios
+ (vm_size_t)usedMemory {
    struct task_basic_info info;
    mach_msg_type_number_t size = sizeof(info);
    kern_return_t kerr = task_info(mach_task_self(), TASK_BASIC_INFO, (task_info_t)&info, &size);
    return (kerr == KERN_SUCCESS) ? info.resident_size : 0; // size in bytes
}

#pragma mark - Network

// http://stackoverflow.com/questions/7946699/iphone-data-usage-tracking-monitoring
+ (ISpyNetworkInfo *)networkInfo {
    static ISpyNetworkInfo *lastNetInfo = nil;
    static ISpyNetworkInfo *curentNetInfo = nil;
    static ISpyNetworkInfo *diffNetInfo = nil;
    if (!curentNetInfo) {
        curentNetInfo = [ISpyNetworkInfo new];
    } else {
        [curentNetInfo reset];
    }
    
    struct ifaddrs *addrs;
    const struct ifaddrs *cursor;
    
    if (getifaddrs(&addrs) == 0) {
        cursor = addrs;
        while (cursor != NULL) {
            if (cursor->ifa_addr->sa_family == AF_LINK) {
                // name of interfaces:
                // en0 is WiFi
                // pdp_ip0 is WWAN
                // lo0 is total
                NSString *name = [NSString stringWithFormat:@"%s", cursor->ifa_name];
                if ([name hasPrefix:@"en"]) {
                    const struct if_data *ifa_data = (struct if_data *)cursor->ifa_data;
                    if(ifa_data != NULL) {
                        curentNetInfo.wifiSent += ifa_data->ifi_obytes;
                        curentNetInfo.wiFiReceived += ifa_data->ifi_ibytes;
                    }
                }
                
                if ([name hasPrefix:@"pdp_ip"]) {
                    const struct if_data *ifa_data = (struct if_data *)cursor->ifa_data;
                    if(ifa_data != NULL) {
                        curentNetInfo.wwanSent += ifa_data->ifi_obytes;
                        curentNetInfo.wwanReceived += ifa_data->ifi_ibytes;
                    }
                }
            }
            
            cursor = cursor->ifa_next;
        }
        
        freeifaddrs(addrs);
    }
    
    if (!lastNetInfo) {
        lastNetInfo = [ISpyNetworkInfo new];
        [lastNetInfo updateWithNetworkInfo:curentNetInfo];
        diffNetInfo = [ISpyNetworkInfo new];
    } else {
        diffNetInfo.wifiSent = curentNetInfo.wifiSent - lastNetInfo.wifiSent;
        diffNetInfo.wiFiReceived = curentNetInfo.wiFiReceived - lastNetInfo.wiFiReceived;
        diffNetInfo.wwanSent = curentNetInfo.wwanSent - lastNetInfo.wwanSent;
        diffNetInfo.wwanReceived = curentNetInfo.wwanReceived - lastNetInfo.wwanReceived;
        
        [lastNetInfo updateWithNetworkInfo:curentNetInfo];
    }
    
    return diffNetInfo;
}

#pragma mark - Helper

+ (NSString *)prettyFormatWithBytes:(unsigned long long)bytes {
    if (bytes < 1024) {
        return [NSString stringWithFormat:@"%dB", (int)bytes];
    } else if (bytes >= 1024 && bytes < 1024 * 1024) {
        return [NSString stringWithFormat:@"%.1fKB", bytes / 1024.0];
    } else if (bytes >= 1024 * 1024 && bytes < 1024 * 1024 * 1024) {
        return [NSString stringWithFormat:@"%.2fMB", bytes / (1024.0 * 1024.0)];
    } else {
        return [NSString stringWithFormat:@"%.3fGB", bytes / (1024.0 * 1024.0 * 1024.0)];
    }
}

@end
