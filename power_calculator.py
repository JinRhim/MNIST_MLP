def read_power_analysis_output(filename):
    # Initialize an empty dictionary to store signal names and their toggle rates
    toggle_rates = {}

    # Open the file and read its contents
    with open(filename, 'r') as file:
        # Flag to detect when we are within the output signal info block
        in_signal_info_block = False

        # Iterate through each line in the file
        for line in file:
            # Check if the line marks the beginning of the output signal info
            if line.strip() == "BEGIN_OUTPUT_SIGNAL_INFO;":
                in_signal_info_block = True
                continue

            # Check if the line marks the end of the output signal info
            if line.strip() == "END_OUTPUT_SIGNAL_INFO;":
                in_signal_info_block = False
                break

            # Process lines only within the output signal info block
            if in_signal_info_block:
                # Clean and split the line to extract parts
                parts = line.split()
                if len(parts) >= 4:
                    # Extract the signal name, toggle rate, and static probability
                    signal_name = parts[0]
                    toggle_rate = parts[2]  # Toggle rate is in transitions per second

                    # Store the toggle rate in the dictionary
                    toggle_rates[signal_name] = toggle_rate

    return toggle_rates

# Use the function to read and process the file
filename = "power_analysis_output"  # Adjust the filename as needed
toggle_rates = read_power_analysis_output(filename)

# Print out the results
for signal, rate in toggle_rates.items():
    print(f"Signal: {signal}, Toggle Rate: {rate} transitions per second")
