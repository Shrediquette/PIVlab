function c = vec_preset_colors()
% Returns 10×2 cell: col 1 = display name, col 2 = [R G B] row vector.
% Row index matches the popup menu Value property.
c = {
    'Green',   [0,   1,   0  ];
    'Cyan',    [0,   0.8, 1  ];
    'Orange',  [1,   0.5, 0  ];
    'Black',   [0,   0,   0  ];
    'White',   [1,   1,   1  ];
    'Red',     [1,   0,   0  ];
    'Blue',    [0,   0.4, 1  ];
    'Yellow',  [1,   1,   0  ];
    'Magenta', [1,   0,   1  ];
    'Gray',    [0.7, 0.7, 0.7];
};
end
