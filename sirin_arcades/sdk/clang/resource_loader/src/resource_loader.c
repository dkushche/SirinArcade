#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <curl/curl.h>
#include <sys/stat.h>
#include <unistd.h>

#define RESOURCE_DIR "/tmp/arcade_resources/"

static size_t write_data(void* ptr, size_t size, size_t nmemb, FILE* stream) {
    return fwrite(ptr, size, nmemb, stream);
}

int load_resource(char* resource_path_url) {
    mkdir(RESOURCE_DIR, 0777);

    char *filename = strrchr(resource_path_url, '/');
    if (!filename) return -1;
    filename++;

    char filepath[1024];
    snprintf(filepath, sizeof(filepath), "%s%s", RESOURCE_DIR, filename);

    CURL *curl = curl_easy_init();
    if (!curl) {
        return -1;
    }

    FILE *file = fopen(filepath, "wb");
    if (!file) {
        curl_easy_cleanup(curl);
        return -1;
    }

    curl_easy_setopt(curl, CURLOPT_URL, resource_path_url);
    curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, write_data);
    curl_easy_setopt(curl, CURLOPT_WRITEDATA, file);

    CURLcode res = curl_easy_perform(curl);

    fclose(file);
    curl_easy_cleanup(curl);

    return (res == CURLE_OK) ? 0 : -1;
}

char* resolve_resource(char* resource_name) {
    static char filepath[1024];
    snprintf(filepath, sizeof(filepath), "%s%s", RESOURCE_DIR, resource_name);

    if (access(filepath, F_OK) == 0) {
        return filepath;
    }

    return NULL;
}

void clean_resources() {
    char command[128];

    snprintf(command, sizeof(command), "rm -rf %s", RESOURCE_DIR);
    system(command);
}
