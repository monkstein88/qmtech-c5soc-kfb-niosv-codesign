#ifndef MAIN_H
#define MAIN_H

/* ========================================================================== */
/*                           Utility Macros                                   */
/* ========================================================================== */

/* Computes the number of elements in an array */
#define COUNTOF(x)  (sizeof(x) / sizeof(x[0]))

/* Prevents unused variable compiler warnings */
#define UNUSED_PARAM(x)     ((void)(x)) 


/* ========================================================================== */
/*                       Bit-Manipulation Macros                              */
/* ========================================================================== */

/* Generates a bitmask at a specific bit position */
#define BIT(pos)            (1UL << (pos))

/* Sets a specific bit to 1 in a register */
#define SET_BIT(reg, pos)   ((reg) |= BIT(pos))

/* Clears a specific bit to 0 in a register */
#define CLEAR_BIT(reg, pos) ((reg) &= ~BIT(pos))

/* Toggles a specific bit (0 to 1, or 1 to 0) */
#define TOGGLE_BIT(reg, pos)((reg) ^= BIT(pos))

/* Checks if a specific bit is set (returns non-zero if true) */
#define READ_BIT(reg, pos)  ((reg) & BIT(pos))


#endif // MAIN_H

