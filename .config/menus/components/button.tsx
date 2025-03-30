import { useOnMouseClick, useOnMouseHover } from "@zenobius/ink-mouse";
import { Box, Text } from "ink";
import { useMemo, useRef, useState, type ComponentProps } from "react";
import { colors } from "../constants";

export function Button({ 
  label, 
  onClick, 
  isSelected = false 
}: { 
  label: string; 
  onClick?: () => void;
  isSelected?: boolean;
}) {
    const ref = useRef<any>(null);
  
    const [hovering, setHovering] = useState(false);
    const [clicking, setClicking] = useState(false);
  
    useOnMouseClick(ref, (event) => {
      setClicking(event);
      if (event && typeof onClick === 'function') {
        onClick();
      }
    });
    useOnMouseHover(ref, setHovering);
  
    const border = useMemo((): ComponentProps<typeof Box>['borderStyle'] => {
      if (clicking) {
        return 'double';
      }
  
      if (hovering || isSelected) {
        return 'singleDouble';
      }
  
      return 'single';
    }, [clicking, hovering, isSelected]);
  
    return (
      <Box
        gap={1}
        paddingX={1}
        paddingY={0}
        ref={ref}
        borderStyle={border}
        borderColor={isSelected ? colors.active : colors.border}
      >
        <Text color={isSelected ? colors.active : undefined}>{isSelected ? `> ${label}` : label}</Text>
      </Box>
    );
}

export function DismissButton({ onClick }: { onClick: () => void }) {
  const ref = useRef<any>(null);
  
  const [hovering, setHovering] = useState(false);
  
  // Direct click handler for dismiss button
  useOnMouseClick(ref, (event) => {
    if (event) {
      // Call the callback directly
      onClick();
    }
  });
  useOnMouseHover(ref, setHovering);

  return (
    <Box 
      ref={ref} 
      width={1} 
      height={1} 
      justifyContent="center" 
      alignItems="center"
    >
      <Text color={hovering ? colors.error : colors.muted}>×</Text>
    </Box>
  );
}