/*
 * Copyright © 2021 -  Dorian & Co - All right reserved
 */

extension StringExtension on String {
  String capitalize() {
    return '${this[0].toUpperCase()}${this.substring(1)}';
  }
}
