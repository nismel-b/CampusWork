import 'package:flutter/material.dart';

/// Composant de filtrage générique
class FilterComponent extends StatefulWidget {
  final List<FilterOption> options;
  final Function(List<String> selectedFilters) onFilterChanged;
  final String? title;
  final bool multiSelect;

  const FilterComponent({
    super.key,
    required this.options,
    required this.onFilterChanged,
    this.title,
    this.multiSelect = true,
  });

  @override
  State<FilterComponent> createState() => _FilterComponentState();
}

class _FilterComponentState extends State<FilterComponent> {
  final Set<String> _selectedFilters = {};

  void _toggleFilter(String filter) {
    setState(() {
      if (widget.multiSelect) {
        if (_selectedFilters.contains(filter)) {
          _selectedFilters.remove(filter);
        } else {
          _selectedFilters.add(filter);
        }
      } else {
        _selectedFilters.clear();
        _selectedFilters.add(filter);
      }
    });
    widget.onFilterChanged(_selectedFilters.toList());
  }

  void _clearFilters() {
    setState(() {
      _selectedFilters.clear();
    });
    widget.onFilterChanged([]);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.title != null) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.title!,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              if (_selectedFilters.isNotEmpty)
                TextButton(
                  onPressed: _clearFilters,
                  child: const Text('Effacer'),
                ),
            ],
          ),
          const SizedBox(height: 8),
        ],
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: widget.options.map((option) {
            final isSelected = _selectedFilters.contains(option.value);
            return FilterChip(
              label: Text(option.label),
              selected: isSelected,
              onSelected: (_) => _toggleFilter(option.value),
              avatar: option.icon != null
                  ? Icon(option.icon, size: 18)
                  : null,
              selectedColor: Theme.of(context).colorScheme.primaryContainer,
            );
          }).toList(),
        ),
      ],
    );
  }
}

/// Option de filtre
class FilterOption {
  final String value;
  final String label;
  final IconData? icon;

  const FilterOption({
    required this.value,
    required this.label,
    this.icon,
  });
}

/// Barre de filtres avec recherche
class FilterBar extends StatelessWidget {
  final TextEditingController searchController;
  final Function(String) onSearchChanged;
  final List<FilterOption> filterOptions;
  final Function(List<String>) onFilterChanged;
  final String searchHint;

  const FilterBar({
    super.key,
    required this.searchController,
    required this.onSearchChanged,
    required this.filterOptions,
    required this.onFilterChanged,
    this.searchHint = 'Rechercher...',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: searchController,
          decoration: InputDecoration(
            hintText: searchHint,
            prefixIcon: const Icon(Icons.search),
            suffixIcon: searchController.text.isNotEmpty
                ? IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                searchController.clear();
                onSearchChanged('');
              },
            )
                : null,
            border: const OutlineInputBorder(),
          ),
          onChanged: onSearchChanged,
        ),
        const SizedBox(height: 16),
        FilterComponent(
          options: filterOptions,
          onFilterChanged: onFilterChanged,
        ),
      ],
    );
  }
}

/// Filtre dropdown simple
class FilterDropdown extends StatelessWidget {
  final String? value;
  final List<FilterOption> options;
  final Function(String?) onChanged;
  final String hint;

  const FilterDropdown({
    super.key,
    this.value,
    required this.options,
    required this.onChanged,
    this.hint = 'Sélectionner',
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        hintText: hint,
      ),
      items: options.map((option) {
        return DropdownMenuItem<String>(
          value: option.value,
          child: Row(
            children: [
              if (option.icon != null) ...[
                Icon(option.icon, size: 20),
                const SizedBox(width: 8),
              ],
              Text(option.label),
            ],
          ),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}

/// Filtre avec catégories
class CategoryFilter extends StatelessWidget {
  final List<FilterCategory> categories;
  final Function(String category, List<String> selectedValues) onFilterChanged;

  const CategoryFilter({
    super.key,
    required this.categories,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: categories.length,
      separatorBuilder: (context, index) => const Divider(height: 24),
      itemBuilder: (context, index) {
        final category = categories[index];
        return FilterComponent(
          title: category.name,
          options: category.options,
          onFilterChanged: (selected) {
            onFilterChanged(category.id, selected);
          },
          multiSelect: category.multiSelect,
        );
      },
    );
  }
}

/// Catégorie de filtre
class FilterCategory {
  final String id;
  final String name;
  final List<FilterOption> options;
  final bool multiSelect;

  const FilterCategory({
    required this.id,
    required this.name,
    required this.options,
    this.multiSelect = true,
  });
}