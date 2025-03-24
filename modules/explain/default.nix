{ lib }:
let
  entry = lib.types.submodules.portable {
    module = { config, name }: {
      options = {
        name = lib.options.create {
          description = "The name of the entry.";
          type = lib.types.string;
          default.value = name;
        };

        description = lib.options.create {
          description = "A description of the entry.";
          type = lib.types.nullish lib.types.string;
          default.value = null;
        };

        data = {
          columns = lib.options.create {
            description = "The names of the columns in this entry's data.";
            type = lib.types.list.of lib.types.string;
            default.value = [ ];
          };

          rows = lib.options.create {
            description = "The rows of data in this entry.";
            type = lib.types.list.of (lib.types.list.required lib.types.string);
            default.value = [ ];
          };
        };

        entries = lib.options.create {
          description = "A list of entries to include in this entry.";
          type = lib.types.list.of entry;
          default.value = [ ];
        };

        result = lib.options.create {
          description = "The serialized result of the entry.";
          type = lib.types.raw;
          writable = false;
          default.value = {
            inherit (config) name description data;
            entries = builtins.map (entry: entry.result) config.entries;
          };
        };
      };
    };
  };
in
{
  options.explain = lib.options.create {
    description = "Structured information about the contents of the Nilla project.";
    type = lib.types.attrs.of entry;
    default.value = { };
  };
}
