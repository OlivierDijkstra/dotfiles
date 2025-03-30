#!/usr/bin/env bun
import {
  MouseProvider
} from '@zenobius/ink-mouse';
import { execa } from 'execa';
import { Box, render, useApp, useInput } from 'ink';
import React, { useState } from 'react';
import { Button, DismissButton } from './components/button';

// Path to the waycap script
const WAYCAP_SCRIPT = `${process.env.HOME}/.config/waybar/modules/waycap/waycap.sh`;

// Menu options
const menuOptions = [
  { label: 'Screenshot Region', action: 'screenshot_region' },
  { label: 'Screenshot Screen', action: 'screenshot_screen' },
  { label: 'Record Region', action: 'record_region' },
  { label: 'Record Screen', action: 'record_screen' },
];

// Menu component
const CapMenu: React.FC = () => {
  const { exit } = useApp();
  const [selectedIndex, setSelectedIndex] = useState(0);

  // Handle keyboard input
  useInput((input, key) => {
    if (key.escape || input === 'q') {
      process.exit(0);
    } else if (key.downArrow || input === 'j') {
      setSelectedIndex((prev) => (prev < menuOptions.length - 1 ? prev + 1 : 0));
    } else if (key.upArrow || input === 'k') {
      setSelectedIndex((prev) => (prev > 0 ? prev - 1 : menuOptions.length - 1));
    } else if (key.return || input === ' ' || input === 'Enter') {
      const option = menuOptions[selectedIndex];
      if (option) {
        executeAction(option.action);
      }
    }
    
    // Support number keys for direct selection
    const numKey = parseInt(input, 10);
    if (!isNaN(numKey) && numKey >= 1 && numKey <= menuOptions.length) {
      setSelectedIndex(numKey - 1);
    }
  });

  // Function to exit the app directly
  const handleExit = () => {
    console.log("Exiting...");
    process.exit(0);
  };

  // Execute the selected action
  const executeAction = async (action: string) => {
    try {
      console.log(`Executing action: ${action}`);
      
      // Run the waycap script with the selected action
      await execa(WAYCAP_SCRIPT, [action], {
        detached: true,
        stdio: 'ignore'
      }).unref();
      
      // Exit this process
      process.exit(0);
    } catch (error) {
      console.error(`Error executing action: ${error}`);
      process.exit(1);
    }
  };

  return (
    <MouseProvider>
      <Box flexDirection="column">
        {/* Header with dismiss button in its own row */}
        <Box justifyContent="flex-end" alignItems="center" height={1} marginBottom={0}>
          <DismissButton onClick={handleExit} />
        </Box>

        {/* Main content - separate from header */}
        <Box 
          flexDirection="column" 
          paddingX={1}
          paddingY={0}
          minHeight={7}
          justifyContent="center"
          alignItems="stretch"
          width="100%"
        >  
          {menuOptions.map((option, index) => (
            <Button 
              key={option.action} 
              label={option.label}
              isSelected={selectedIndex === index}
              onClick={() => executeAction(option.action)}
            />
          ))}
        </Box>
      </Box>
    </MouseProvider>
  );
};

// Render the app
render(<CapMenu />);
