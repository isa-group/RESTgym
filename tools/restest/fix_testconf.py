import yaml
import argparse
import os

def main():
  parser = argparse.ArgumentParser(description="Process a YAML test configuration file and create a modified version.")
  parser.add_argument('input_file', help='Path to the input YAML file (e.g., testConf.yaml)')
  parser.add_argument('output_file', help='Path to the output YAML file (e.g., modified-testConf.yaml)')
  args = parser.parse_args()

  # Check if input file exists
  if not os.path.exists(args.input_file):
    print(f"Error: Input file '{args.input_file}' does not exist.")
    return

  # Load the YAML file
  with open(args.input_file, 'r') as file:
    data = yaml.safe_load(file)

  # Modification logic: if there are two parameters with the same "name" but different "in", set "weight" to null in both
  modified = False
  for operation in data['testConfiguration']['operations']:
    if 'testParameters' not in operation or not operation['testParameters']:
      continue
    param_name_in_map = {}
    for param in operation['testParameters']:
      param_name = param['name']
      param_in = param['in']
      if param_name not in param_name_in_map:
        param_name_in_map[param_name] = set()
      param_name_in_map[param_name].add(param_in)

    for param in operation['testParameters']:
      param_name = param['name']
      if len(param_name_in_map[param_name]) > 1:
        param['weight'] = None
        modified = True

  if modified:
    with open(args.output_file, 'w') as file:
      yaml.dump(data, file, default_flow_style=False)
    print(f"Modified YAML saved to {args.output_file}")
  else:
    print(f"No modifications were necessary.")


if __name__ == "__main__":
  main()
