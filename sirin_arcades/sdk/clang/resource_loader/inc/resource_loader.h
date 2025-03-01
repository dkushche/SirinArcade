#ifndef RESOURCE_LOADER_H
#define RESOURCE_LOADER_H

int load_resource(char* resource_path_url);
char* resolve_resource(char* resource_name);
void clean_resources();

#endif // RESOURCE_LOADER_H
